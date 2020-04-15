namespace {{rootNs}};

use PhalconPlus\App\Module\AbstractModule as AppModule;

use {{rootNs}}\Events\EventProvider;
use {{rootNs}}\Providers\ServiceProvider;

use Ph\{Di, Config, App, Sys};

class Module extends AppModule
{
    public function registerAutoloaders()
    {
        Di::get('loader')->registerNamespaces([
            __NAMESPACE__.'\\Tasks'        => __DIR__.'/tasks/',
            __NAMESPACE__.'\\Exceptions'   => __DIR__.'/exceptions/',
            __NAMESPACE__.'\\Events'       => __DIR__.'/events/',
            __NAMESPACE__."\\Providers"    => __DIR__.'/providers/',
            __NAMESPACE__.'\\Models'       => $this->getDir().'/src/models/',
            __NAMESPACE__.'\\Protos'       => $this->getDir().'/src/protos/',
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
