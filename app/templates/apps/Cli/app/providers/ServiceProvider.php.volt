namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use PhalconPlus\App\Module\AbstractModule as AppModule;
use Ph\{Config, App, };

class ServiceProvider implements ServiceProviderInterface
{
    private $module;

    public function __construct(AppModule $module)
    {
        $this->module = $module;    
    }

    public function register(DiInterface $di) : void
    {
        if($this->module->isPrimary()) {
            $di->register(new RouterServiceProvider($this->module));
            $di->register(new DispatcherServiceProvider($this->module));
        }
        $di->register(new DatabaseServiceProvider());
        $di->register(new RedisServiceProvider());
        $di->register(new LoggerServiceProvider());
        $di->register(new CryptServiceProvider());
    }

    public static function destroy(DiInterface $di) 
    {
        (new DatabaseServiceProvider())->destrory($di);
    }
}