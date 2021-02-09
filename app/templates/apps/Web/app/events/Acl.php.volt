namespace {{rootNs}}\Events;

use Phalcon\Events\Event;
use PhalconPlus\Contracts\EventAttachable;
use Phalcon\Acl\Adapter\AbstractAdapter;
use Ph\{
    EventsManager,
    Acl as PhAcl,
    Di,
};

class Acl implements EventAttachable
{
    public function __construct()
    {
        PhAcl::setEventsManager(Di::get('eventsManager'));
    }

    public function attach($param = null)
    {
        EventsManager::attach("acl", $this);
    }

    public function beforeCheckAccess(Event $event, AbstractAdapter $acl)
    {
        // 
    }
}