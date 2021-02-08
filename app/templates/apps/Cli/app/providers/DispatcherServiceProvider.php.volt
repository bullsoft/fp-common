namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use PhalconPlus\App\Module\AbstractModule as AppModule;

use Ph\{Config,};

class DispatcherServiceProvider implements ServiceProviderInterface
{
    protected $module = null;

    public function __construct(AppModule $module)
    {
        $this->module = $module;
    }

    public function register(DiInterface $di) : void
    {
        $di->setShared('dispatcher', function() {
            $dispatcher = new \Phalcon\Cli\Dispatcher();
            $dispatcher->setDefaultNamespace("{{rootNs}}\Tasks\\");
            $dispatcher->setDefaultTask("hello");
            return $dispatcher;
        });
    }
}