namespace {{rootNs}}\Providers;

use Phalcon\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use Phalcon\Session\Adapter\Redis as SessionRedis;
use Phalcon\Storage\AdapterFactory;
use Ph\{Config,};

class SessionServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared('session', function () {
            $version = \Phalcon\Version::getPart(
                \Phalcon\Version::VERSION_MAJOR
            );
            if($version < 4) {
                $session = new SessionRedis(Config::get('session')->toArray());
                $session->start();
                return $session;
            } else {
                $factory = new AdapterFactory();
                $session = new SessionRedis($factory, Config::get('session')->toArray());
                return $session;
            }
        });
    }
}