namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use Phalcon\Mvc\View\Engine\Volt as VoltEngine;
use PhalconPlus\Volt\Extension\PhpFunction as VoltPhpFunction;
use Ph\{Config,};

class ViewServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared('view', function() {
            $view = new \Phalcon\Mvc\View();
            $view->setViewsDir(Config::path('view.dir'));
            $view->registerEngines(array(
                ".volt" => function($view) {
                    $volt = new VoltEngine($view, $this);
                    $volt->setOptions(array(
                        "always"     => true,
                        "path"      => Config::path('view.path'),
                        "extension" => Config::path('view.extension'),
                    ));
                    // 如果模板缓存目录不存在，则创建它
                    if(!file_exists(Config::path('view.path'))) {
                        mkdir(Config::path('view.path'), 0777, true);
                    }
                    $compiler = $volt->getCompiler();
                    $ext = new VoltPhpFunction();
                    $ext->setCustNamespace("{{rootNs}}\\Plugins\\");
                    $compiler->addExtension($ext);
                    return $volt;
                }
            ));
            return $view;
        });
    }
}