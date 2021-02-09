<?php
namespace PhalconPlus\DevTools\Tasks;

use PhalconPlus\DevTools\Library\Process;
use Ph\Sys;

class ModuleTask extends BaseTask
{
    public function mainAction()
    {
        $this->dispatcher->forward([
            "controller" => "module",
            "action" => "help"
        ]);
        return ;
    }

    public function listAction()
    {
        $this->cli->br()->info("您的Phalcon+模块列表：");
        $list = [];
        $modules = $this->module->getList();
        foreach($modules as $dirname => $item) {
            $newItem = [];
            $newItem['name'] = "<light_green>".$item['name']. "</light_green>";
            $newItem['namespace'] = $item['def']->config()->path('application.ns');
            $newItem['mode'] = $item['def']->getMode();
            $newItem ['create_time'] = $item['create_time'];
            $newItem['running_status'] = " - ";
            if(in_array($newItem['mode'], ['Srv', 'Web'])) {
                $process = new Process($item['def']->getDir());
                $result = $process->ps($this->module->getPidPath($item['def']));
                if($result) {
                    $statusText  = "<background_green><white>运行中</white></background_green> ";
                    $newItem['running_status'] = $statusText. $process->getPsCmd();
                }
            }
            $list[] = $newItem;
        }

        $this->cli->table($list);
    }

    public function createAction()
    {
        $this->dispatcher->forward([
            "controller" => "create-module",
            "action" => "main"
        ]);
        return ;
    }

    public function installAction($argv)
    {
        global $version;
        if($version > 3) {
            $argv = func_get_args();
        }
        if(empty($argv)) {
            $this->cli->error("请输入要安装的模块地址");
            exit(1);
        }
        $repo = $argv[0];
        $alis = $argv[1] ?? "";
        $this->cli->info("正在克隆...");
        $process = new Process(Sys::getRootDir());
        $cmd = "git clone {$repo} {$alis}";
        try {
            $process->start($cmd);
        }catch(\Exception $e) {
            $this->cli->backgroundRed($e->getMessage());
            $this->cli->info("...正在退出");
            exit(1);
        }
        $name = $alis ?: basename($repo, ".git");
        $def = $this->module->check($name);
        if(!$def) {
            $this->cli->error("{$name}不是合法的Phalcon+模块，即将删除...");
            $this->filesystem->deleteDir($name);
        }
        $this->cli->info("...完成");
    }

    public function helpAction()
    {
        $this->cli->out('<light_yellow>帮助:<light_yellow>');
        $this->cli->out('    Phalcon+模块工具');
        $this->cli->br();
        $this->cli->out('<light_yellow>使用方式:<light_yellow>');
        $this->cli->out('    - 创建: /path/to/fp-devtool module create');
        $this->cli->out('    - 列表: /path/to/fp-devtool module list');
    }

    public function cleanAllAction()
    {
        $this->module->cleanAll();
    }
}