namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use Phalcon\Mvc\Model\Metadata\Memory as MetaData;

use Ph\{Config, Di};

class DatabaseServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        // Register db write service
        $di->attempt('db', function() {
            $mysql = new \PhalconPlus\Db\Mysql($this, "db");
            $conn = $mysql->getConnection();
            $conn->setEventsManager(Di::get('eventsManager'));
            return $conn;
        }, true);

        // Register db read service
        $di->attempt('dbRead', function() {
            $mysql = new \PhalconPlus\Db\Mysql($this, "db");
            $conn = $mysql->getConnection();
            $conn->setEventsManager(Di::get('eventsManager'));
            return $conn;
        }, true);

        $di->attempt('modelsMetadata', new MetaData(), true);
    }

    public function destrory(DiInterface $di)
    {
        $di->remove('db');
        $di->remove('dbRead');
    }
}