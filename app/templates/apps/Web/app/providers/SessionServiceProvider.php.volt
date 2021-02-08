namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
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
                $session = new SessionRedis(Config::get('redis')->toArray());
                $session->start();
                return $session;
            } else {
                $factory1 = new \Phalcon\Storage\SerializerFactory();
                $factory2 = new AdapterFactory($factory1);

                $sessionAdapter = new SessionRedis($factory2, Config::get('redis')->toArray());
                $manager = new \Phalcon\Session\Manager(Config::get('session')->toArray());
                $manager->setAdapter($sessionAdapter);
                return $manager;
            }
        });
    }
}