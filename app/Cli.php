<?php
namespace PhalconPlus\DevTools;
use PhalconPlus\App\Module\AbstractModule as AppModule;
use PhalconPlus\DevTools\Providers\ServiceProvider;
use Ph\{Di, Config, App, Sys, };

class Cli extends AppModule
{
    public function registerAutoloaders()
    {
        Di::get('loader')->registerNamespaces(array(
            __NAMESPACE__.'\\Tasks'     => __DIR__.'/tasks/',
            __NAMESPACE__."\\Library"   => __DIR__.'/library/',
            __NAMESPACE__."\\Providers" => __DIR__.'/providers/',
        ), true)->register();
    }

    public function registerServices()
    {
        Di::register(new ServiceProvider($this));
    }
}

