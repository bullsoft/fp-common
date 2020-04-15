<?php
namespace PhalconPlus\DevTools\Tasks;
use PhalconPlus\DevTools\Library\Process;
use Ph\{
    App, Di,
};
class ServerTask extends BaseTask
{
    public function mainAction()
    {
        $this->dispatcher->forward([
            "controller" => "server",
            "action" => "help"
        ]);
        return ;
    }

    public function startAction($argv)
    {
        global $version;
        if($version > 3) {
            $argv = func_get_args();
        }
        if(empty($argv)) {
            $this->cli->error("致命错误：请指定您要运行的模块！");
            exit(1);
        }
        $module = $argv[0];

        $def = $this->module->check($module);
        if(false == $def) {
            $this->cli->backgroundRed("模块{$module}不存在或不合法，请更换名称再试！");
            exit(2);
        }
        $config = $def->config();
        $port = $argv[1] ?? parse_url($config->application->url, \PHP_URL_PORT);
        $port = $port ?? 8000;

        $cwd = $def->getDir();
        $process = new Process($cwd);

        $cmd = "php -S 0.0.0.0:{$port} -t public/ .htrouter.php";
        $pidPath = $this->module->getPidPath($def);
        $logPath = $this->module->getAccessLogPath($def);

        $this->cli->info("正在为您启动服务器...");

        try {
            $procStatus = $process->start($cmd, $pidPath, $logPath);
        }catch(\Exception $e) {
            $this->cli->backgroundRed($e->getMessage());
            $this->cli->info("...正在退出");
            exit(3);
        }
        $this->cli->json($procStatus);
        $this->cli->info("... 启动成功，请使用 http://127.0.0.1:{$port} 访问");
    }

    public function stopAction($argv)
    {
        global $version;
        if($version > 3) {
            $argv = func_get_args();
        }
        if(empty($argv)) {
            $this->cli->error("致命错误：请指定您要运行的模块！");
            exit(1);
        }
        $module = $argv[0];

        $def = $this->module->check($module);
        if(false == $def) {
            $this->cli->backgroundRed("模块{$module}不存在或不合法，请更换名称再试！");
            exit(2);
        }
        $cwd = $def->getDir();
        $pidPath = $this->module->getPidPath($def);
        $pid = (int) trim(file_get_contents($pidPath));

        $process = new Process($cwd);
        $this->cli->info("正在关闭服务器... ");
        try {
            $result = $process->stop($pidPath);
        } catch(\Exception $e) {
            $this->cli->backgroundRed($e->getMessage());
            exit(3);
        }
        
        $this->cli->json([
            "module" => $module,
            "pid" => $pid,
            "started_command" => $process->getPsCmd(),
        ]);

        if($result) {
            $this->cli->info("... 关闭成功");
        } else {
            $this->cli->info("... 关闭失败");
        }
    }

    public function restartAction($argv)
    {
        global $version;
        if($version > 3) {
            $argv = func_get_args();
        }
        if(empty($argv)) {
            $this->cli->error("致命错误：请指定您要运行的模块！");
            exit(1);
        }
        $module = $argv[0];

        $def = $this->module->check($module);
        if(false == $def) {
            $this->cli->backgroundRed("模块{$module}不存在或不合法，请更换名称再试！");
            exit(2);
        }
        $cwd = $def->getDir();
        $process = new Process($cwd);
        try {
            $pidPath = $this->module->getPidPath($def);
            $logPath = $this->module->getAccessLogPath($def);
            $procStatus = $process->restart($pidPath, $logPath);
        } catch(\Exception $e) {
            $this->cli->error($e->getMessage());
            exit(3);
        }
        $this->cli->json($procStatus);
        $this->cli->info("... 重启成功， ".$process->getPsCmd());
    }

    public function listAction()
    {
        $this->cli->br()->info("您的Phalcon+服务列表：");
        $list = [];
        $modules = $this->module->getList();
        foreach($modules as $item) {
            $newItem = [];
            $newItem['name'] = "<light_green>".$item['name']. "</light_green>";
            $newItem['namespace'] = $item['def']->config()->path('application.ns');
            $newItem['mode'] = $item['def']->getMode();
            $newItem['create_time'] = $item['create_time'];
            $process = new Process($item['def']->getDir());
            $ret = $process->ps($this->module->getPidPath($item['def']));
            if($ret) {
                $newItem['running_command'] = $process->getPsCmd();
                $list[] = $newItem;
            }
        }

        if(empty($list)) {
            $this->cli->tab()->out("空！空即是色！放开那个女孩...")->br();
        } else {
            $this->cli->table($list);
        }
    }

    public function helpAction()
    {
        $this->cli->out('<light_yellow>帮助:<light_yellow>');
        $this->cli->out('    使用PHP内置服务器运行Phalcon+模块');
        $this->cli->br();
        $this->cli->out('<light_yellow>使用方式:<light_yellow>');
        $this->cli->out('    - 启动: /path/to/fp-devtool server start <light_red>moduleName</light_red> <blue>[listenPort]</blue>');
        $this->cli->out('    - 关闭: /path/to/fp-devtool server stop <light_red>moduleName</light_red>');
        $this->cli->out('    - 列表: /path/to/fp-devtool server list');
    }

}
