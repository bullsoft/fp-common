<?php
namespace PhalconPlus\DevTools\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use PhalconPlus\Base\SimpleRequest;
use PhalconPlus\RPC\Client\Adapter\{
    Local as LocalRpc,
};
use PhalconPlus\Base\ProtoBuffer;
use App\Com\Protos\ExceptionBase;
use Ph\{App, Log};

class RpcServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->set("rpc", function($name, $service, $args=[]) {
            App::import($name);
            $client = new LocalRpc($this);
            $request = null;
	        if(is_object($args) && $args instanceof ProtoBuffer) {
	            $request = $args;
	        } elseif(is_array($args)) {
	            $request = new SimpleRequest();
	            $request->setParams($args);
	        }
            [$service, $method] = explode("::", $service);
	        return $client->callByObject([
	            "service" => $service,
	            "method"  => $method,
	            "args"    => $request,
	            "logId"   => Log::getProcessorVar("logId"),
            ]);
        });
    }
}