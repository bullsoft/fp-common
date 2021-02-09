namespace {{rootNs}};

use PhalconPlus\Enum\RunEnv;
use PhalconPlus\App\Module\AbstractModule as AppModule;
use Phalcon\Mvc\Application as MvcApplication;
use PhalconPlus\App\Engine\Web as WebEngine;

use {{rootNs}}\Providers\ServiceProvider;
use {{rootNs}}\Events\EventProvider;

use Ph\{Di, Config, App, Sys};

class Module extends AppModule
{
    public function registerAutoloaders()
    {
        Di::get('loader')->registerNamespaces([
            __NAMESPACE__.'\\Controllers'        => __DIR__.'/controllers/',
            __NAMESPACE__.'\\Controllers\\Apis'  => __DIR__.'/controllers/apis/',
            __NAMESPACE__.'\\Plugins'      => __DIR__.'/plugins/',
            __NAMESPACE__.'\\Exceptions'   => __DIR__.'/exceptions/',
            __NAMESPACE__.'\\Events'       => __DIR__.'/events/',
            __NAMESPACE__.'\\Routes'       => __DIR__.'/routes/',
            __NAMESPACE__.'\\Auth'         => __DIR__.'/auth/',
            __NAMESPACE__."\\Providers"    => __DIR__.'/providers/',
            __NAMESPACE__.'\\Services'     => $this->getDir().'/src/services/',
            __NAMESPACE__.'\\Models'       => $this->getDir().'/src/models/',
            __NAMESPACE__.'\\Protos'       => $this->getDir().'/src/protos/',
            __NAMESPACE__.'\\Tasks'        => $this->getDir().'/cli/tasks/',
        ], true)->register();
    }

    public function registerServices()
    {
        $that = $this;
        if($this->isPrimary()) {
            Di::set('myConfig', function() use($that) {
                return $that->config();
            });
        }
        Di::register(new ServiceProvider($this));
    }

    public function registerEvents()
    {
        if($this->isPrimary()) {
            // Attach Events
            (new EventProvider($this))->attach();
        }
    }

    public function registerEngine($request = null) : AppModule
    {
        if($this->isPrimary() && $this->isWeb()) {
            $handler = new MvcApplication($this->di());
            $custEngine = new WebEngine($this, $handler);
            $this->engine = $custEngine;
        } else {
            Parent::registerEngine();
        }
        return $this;
    }
}
