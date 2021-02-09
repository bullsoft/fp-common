namespace {{rootNs}};

use PhalconPlus\Enum\RunEnv;
use PhalconPlus\App\Module\AbstractModule as AppModule;

use {{rootNs}}\Providers\ServiceProvider;
use {{rootNs}}\Events\EventProvider;

use Ph\{Di, Config, App, Sys};

class Module extends AppModule
{
    public function registerAutoloaders()
    {
        Di::get('loader')->registerNamespaces([
            __NAMESPACE__.'\\Services'     => __DIR__.'/services/',
            __NAMESPACE__.'\\Exceptions'   => __DIR__.'/exceptions/',
            __NAMESPACE__.'\\Events'       => __DIR__.'/events/',
            __NAMESPACE__."\\Providers"    => __DIR__.'/providers/',
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
}
