<?php
namespace PhalconPlus\DevTools\Library;

use App\Com\Protos\ExceptionBase;

class Process
{
    protected $cwd = "";
    protected $isRunning = false;
    protected $psCmd  = "";

    public function __construct(string $cwd)
    {
        $this->cwd = $cwd;    
    }

    public function start(string $cmd, string $pidPath = "", string $stdfile = "")
    {
        $ret = $this->ps($pidPath);
        if($ret) {
            ExceptionBase::throw("Process is already running...");
        }
        if(!empty($stdfile)) {
            $descriptorSpec = array(
                0 => array("pipe", "r"),            // 标准输入，子进程从此管道中读取数据
                1 => array("file", $stdfile, "a"),  // 标准输出，子进程向此管道中写入数据
                2 => array("file", $stdfile, "a"),  // 标准错误
                3 => array("pipe", "w"),
            );
        } else {
            $descriptorSpec = array(
                0 => array("pipe", "r"),  // 标准输入，子进程从此管道中读取数据
                1 => array("pipe", "w"),  // 标准输出，子进程向此管道中写入数据
                2 => array("pipe", "w"),  // 标准错误
                3 => array("pipe", "w"),
            );
        }
        // See https://unix.stackexchange.com/questions/71205/background-process-pipe-input
        $cmd = '{ (' . escapeshellcmd($cmd) . ') <&3 3<&- 3>/dev/null & } 3<&0;';
        if(!empty($pidPath)) {
            $cmd .= 'pid=$!; echo $pid > '.$pidPath;
        }
        $proc = proc_open($cmd, $descriptorSpec, $pipes, $this->cwd);
        if(!is_resource($proc)) {
            ExceptionBase::throw("Process start failed...");
        }

        stream_set_blocking($pipes[0], 0);
        stream_set_blocking($pipes[3], 0);

        if(empty($stdfile)) {
            echo stream_get_contents($pipes[1]) . PHP_EOL;
            echo stream_get_contents($pipes[2]) . PHP_EOL;
            fclose($pipes[1]);
            fclose($pipes[2]);
        }

        $procStatus = proc_get_status($proc);
        /*
            $procStatus =
            {
                "command": "php -S 0.0.0.0:8181 -t public/ .htrouter.php &",
                "pid": 66671,
                "running": true,
                "signaled": false,
                "stopped": false,
                "exitcode": -1,
                "termsig": 0,
                "stopsig": 0
            }
        */
        proc_close($proc);

        $this->isRunning = $procStatus["running"];
        return $procStatus;
    }

    public function ps(string $pidPath, bool $isPid = false)
    {
        if(empty($pidPath)) {
            return false;
        }
        if($isPid) {
            $pid = $pidPath;
        } elseif(is_file($pidPath)) {
            $pid = file_get_contents($pidPath);
        } else {
            return false;
        }

        $phpOS = strtolower(PHP_OS);
        $output = [];

        if($phpOS == "darwin") {
            exec("ps -p {$pid}", $output);
        } elseif($phpOS == "linux") {
            exec("ps -P {$pid}", $output);
        }

        if(isset($output[1])) {
            $this->isRunning = true;
            $this->psCmd = strstr($output[1], "php");
            return $pid;
        } else {
            $this->isRunning = false;
            $this->psCmd = "";
            unlink($pidPath);
            return false;
        }
    }

    public function restart(string $pidPath, string $stdfile = "")
    {
        $ret = $this->ps($pidPath);
        if(!$ret) {
            ExceptionBase::throw("Process is not running ...");
        }
        $cmd = $this->psCmd;
        $ret = $this->stop($pidPath);
        if(!$ret) {
            ExceptionBase::throw("Process did not stop ...");
        }
        return $this->start($cmd, $pidPath, $stdfile);
    }

    public function stop(string $pidPath)
    {
        $signal = 9;
        if(!$pidPath || !is_file($pidPath)) {
            ExceptionBase::throw("It's not a regular pid file: " . $pidPath);
        }
        $pid = $this->ps($pidPath);
        if(!$pid) {
            ExceptionBase::throw("Process is not running ...");
        }
        if (function_exists('posix_kill')) {
            $ok = @posix_kill($pid, $signal);
        } elseif ($ok = proc_open(sprintf('kill -%d %d', $signal, $pid), [2 => ['pipe', 'w']], $pipes)) {
            $ok = false === fgets($pipes[2]);
        }
        if (!$ok) {
            return false;
        }
        $this->isRunning = false;
        unlink($pidPath);
        return true;
    }

    public function getPsCmd()
    {
        return $this->psCmd;
    }

    public function isRunning()
    {
        return $this->isRunning === true;
    }
}