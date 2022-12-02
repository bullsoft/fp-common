<?php
namespace PhalconPlus\DevTools\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use Phalcon\Mvc\View;
use Phalcon\Mvc\View\Engine\Volt;
use Ph\{Config, App, Sys};

class VoltServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->set('volt', function(string $templatePath) {
            $view = new View();
            $view->setDI(App::di());
            $view->setViewsDir($templatePath);

            $cachePath = '/common/var/cache/compiled/';
            $compiledPath = Sys::getRootDir().$cachePath;
            if(!\file_exists($compiledPath)) {
                mkdir($compiledPath, 0777, true);
            }
            $volt = new Volt($view, App::di());
            $volt->setOptions(array(
                "always" => true,
                "separator" => "#",
                "path" => $compiledPath,
            ));
            return $volt;
        });
    }
}