namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;

use Ph\{Config,};

class UrlServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared("url", function() {
            if (class_exists("\Phalcon\Url")) {  // for Phalcon 4.0
                $url = new \Phalcon\Url();
            } elseif(class_exists("\Phalcon\Mvc\Url")) {
                $url = new \Phalcon\Mvc\Url();   // for Phalcon 3.x
            } else {
                // nothing here
            }
            $url->setBaseUri(Config::path('application.url'));
            $url->setStaticBaseUri(Config::path('application.staticUrl'));
            return $url;
        });
    }
}