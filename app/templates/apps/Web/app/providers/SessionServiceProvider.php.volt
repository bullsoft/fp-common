namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use Phalcon\Session\Adapter\Redis as SessionRedis;
use Phalcon\Storage\AdapterFactory;
use Phalcon\Storage\SerializerFactory;
use Phalcon\Session\Manager as SessionManager;
use Phalcon\Support\Version;
use Plus\{Config,};

class SessionServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared('session', function () {
            $version = (new Version())->getPart(
                Version::VERSION_MAJOR
            );
            if($version < 4) {
                $session = new SessionRedis(Config::get('session')->toArray());
                $session->start();
                return $session;
            } else {
                $serializer = new SerializerFactory();
                $factory = new AdapterFactory($serializer);
                $adapter = new SessionRedis($factory, Config::get('session')->toArray());
                $session = new SessionManager(Config::get('session')->toArray());
                $session->setAdapter($adapter);
                return $session;
            }
        });
    }
}