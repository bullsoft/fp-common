namespace {{rootNs}}\Events;

use Ph\EventsManager;
use Phalcon\Events\Event;
use PhalconPlus\Contracts\EventAttachable;
use Phalcon\Db\Adapter\Pdo\AbstractPdo as PdoAdapter;

class Db implements EventAttachable
{
    public function __construct()
    {
        // 
    }

    /**
     * @param $param
     */
    public function attach($param = null)
    {
        EventsManager::attach("db", $this);
    }

    public function beforeQuery(Event $event, PdoAdapter $pdo, $context = null)
    {
        // 
    }
}