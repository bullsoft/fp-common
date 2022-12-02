namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use Phalcon\Url as PhUrl;
use Phalcon\Mvc\Url as MvcUrl;
use Plus\{Config,};

class UrlServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared("url", function() {
            if (class_exists("\Phalcon\Url")) {  // for Phalcon 4.0
                $url = new PhUrl();
            } elseif(class_exists("\Phalcon\Mvc\Url")) {
                $url = new MvcUrl($di->get("router"));   // for Phalcon 3.x, 5.x
            } else {
                throw new \Exception('Class "Phalcon\Url" or "Phalcon\Mvc\Url" not exists');
            }
            $url->setBaseUri(Config::path('application.url'));
            $url->setStaticBaseUri(Config::path('application.staticUrl'));
            return $url;
        });
    }
}