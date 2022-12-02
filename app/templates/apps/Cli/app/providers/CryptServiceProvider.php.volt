namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use Phalcon\Encryption\Crypt;
use Ph\{Config, App, };

class CryptServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared('crypt', function () {
            $crypt = new Crypt();
            $crypt->setKey(Config::path("application.key"));
            return $crypt;
        });
    }
}