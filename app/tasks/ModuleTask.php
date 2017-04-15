<?php
namespace PhalconPlus\DevTools\Tasks;
use League\Flysystem\Filesystem;
use League\Flysystem\Adapter\Local as LocalAdapter;

class ModuleTask extends \Phalcon\CLI\TASK
{
    protected $skipDirs = [
        "vendor",
    ];

    public function mainAction()
    {
        $this->cli->br()->info("您的Phalcon+模块列表：");
        $filesystem = new Filesystem(new LocalAdapter(APP_ROOT_DIR));
        $contents = $filesystem->listContents();
        $modules = [];
        foreach($contents as $item) {
            if($item['type'] == "file") continue;
            $module = $item['basename'];
            if(in_array($module, $this->skipDirs)) continue;
            $configPath = "{$module}/app/config/" . APP_ENV . ".php";
            if(!$filesystem->has($configPath)) {
                $configPath = "{$module}/app/config/config.php";
            }
            $newItem = [];
            $config = new \Phalcon\Config($this->di->getBootstrap()->load(APP_ROOT_DIR . $configPath));

            $newItem['name'] = "<light_green>".$config->application->name. "</light_green>";
            $newItem['namespace'] = $config->application->ns;
            $newItem['mode'] = $config->application->mode;
            $newItem ['create_time'] = date("Y-m-d H:i:s", $item['timestamp']);
            $newItem['running_status'] = " - ";
            if(in_array($newItem['mode'], ['Srv', 'Web'])) {
                $pidPath = "{$module}/server.pid";
                if($filesystem->has($pidPath)) {
                    $pid = file_get_contents($pidPath);
                    $output = [];
                    exec("ps -p {$pid}", $output);
                    $newItem['running_status'] = join(" ", array_slice(str_getcsv($output[1], " "), -6));
                }
            }
            $modules[] = $newItem;
        }

        $this->cli->table($modules);
    }

    public function listAction()
    {
        $this->dispatcher->forward([
            "controller" => "module",
            "action" => "main"
        ]);
        return ;
    }

    public function createAction()
    {
        $this->dispatcher->forward([
            "controller" => "create-module",
            "action" => "main"
        ]);
        return ;
    }
}