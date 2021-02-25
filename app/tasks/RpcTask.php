<?php
namespace PhalconPlus\DevTools\Tasks;
use PhalconPlus\Base\SimpleRequest as SimpleRequest;
use PhalconPlus\Base\SimpleResponse as SimpleResponse;
use League\Flysystem\Filesystem;
use League\Flysystem\Adapter\Local as LocalAdapter;
use Ph\App;

class RpcTask extends BaseTask
{
    public function callAction($argv)
    {
        global $version;
        if($version > 3) {
            $argv = func_get_args();
        }
        
        if(count($argv) < 2) {
            $this->cli->backgroundRed("请指定模块名称和Service名称！");
            exit(1);
        }
        $name = $argv[0];
        $def = $this->module->check($name);
        $ns = rtrim($def->config()->path("application.ns"), "\\");
        $service = $argv[1];
        $service = $ns . "\\Services\\" . $service;
        $args = isset($argv[2])?json_decode($argv[2], true):[];


        $this->cli->red("====== RPC Start ======");
        $this->cli->text("Target Service: {$service}")->br();
        $this->cli->green("###### Request ######");
        var_export($args);

        $ret = App::rpc($name, $service, $args);
       
        $this->cli->br()->green("###### Response ######");
        var_export($ret);
        $this->cli->br()->red("====== RPC End ======");
    }
}
