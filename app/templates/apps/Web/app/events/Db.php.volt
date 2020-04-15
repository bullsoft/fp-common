namespace {{rootNs}}\Events;

use Ph\EventsManager;
use Phalcon\Events\Event;
use PhalconPlus\Contracts\EventAttachable;

class Db implements EventAttachable
{
    public function __construct()
    {
        // 
    }

    public function attach($param = null)
    {
        EventsManager::attach("db", $this);
    }

    public function beforeQuery(Event $event, \Phalcon\Db\Adapter $pdo, $context = null)
    {
        // 
    }
}