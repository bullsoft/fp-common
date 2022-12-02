namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use PhalconPlus\App\Module\AbstractModule as AppModule;
use Phalcon\Mvc\Router as MvcRouter;
use Phalcon\Cli\Router as CliRouter;
use Plus\{Config, App, };

class RouterServiceProvider implements ServiceProviderInterface
{
    protected $module = null;

    public function __construct(AppModule $module)
    {
        $this->module = $module;
    }

    public function register(DiInterface $di) : void
    {
        if($this->module->isWeb()) {
            $di->setShared('router', function () {
                $router = new MvcRouter(false);
                $router->removeExtraSlashes(true);
                // $router->setUriSource(MvcRouter::URI_SOURCE_SERVER_REQUEST_URI);
                $router->mount(new \{{rootNs}}\Routes\Bare());
                $router->mount(new \{{rootNs}}\Routes\Api());
                return $router;
            });
        } elseif($this->module->isCli()) {

            $di->setShared('router', function() {
                return new CliRouter();
            });
            
        }
    }
}