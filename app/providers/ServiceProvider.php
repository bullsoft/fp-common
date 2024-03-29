<?php
namespace PhalconPlus\DevTools\Providers;

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
            $di->register(new RouterServiceProvider());
            $di->register(new DispatcherServiceProvider());
        }
        $di->register(new LoggerServiceProvider());
        $di->register(new VoltServiceProvider());
        $di->register(new RpcServiceProvider());
    }
}