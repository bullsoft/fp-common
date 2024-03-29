namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;

use Ph\{Config, App, };

class CookieServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared('cookie', function () {
            $cookie = new \Phalcon\Http\Response\Cookies();
            return $cookie;
        });
    }
}