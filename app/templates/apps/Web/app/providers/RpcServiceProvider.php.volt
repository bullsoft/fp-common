namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use PhalconPlus\RPC\Client\Adapter\{
    Local as LocalRpc,
    Simple as SimpleRpc,
    Yar as YarRpc,
};

use Plus\{Config, App, };

class RpcServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->set("rpc", function() use ($di) {
            $client = null;
            if(Config::path('demoRpc.debug') == true) {
                App::dependModule(Config::path('demoRpc.module')); // 可能需要修改
                $client = new LocalRpc($this);
            } else {
                $remoteUrls = Config::path('demoRpc.serverUrl');
                if(Config::path("demoRpc.serverType") == "yar") {
                    $client = new YarRpc($remoteUrls->toArray());
                } else {
                    $client = new SimpleRpc($remoteUrls->toArray());
                }
            }
            $client->setDI($di);
            return $client;
        });
    }
}