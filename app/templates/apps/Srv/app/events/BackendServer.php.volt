namespace {{rootNs}}\Events;

use Phalcon\Events\Event;
use PhalconPlus\Rpc\Server\AbstractServer;
use PhalconPlus\Contracts\EventAttachable;
use Ph\EventsManager;

class BackendServer implements EventAttachable
{
    public function attach($param = null)
    {
        EventsManager::attach("backend-server", $this);
    }
	
    public function requestCheck(Event $event, AbstractServer $server, array $context)
    {
		// [service, method, rawData]
    }
	
    public function beforeExecute(Event $event, AbstractServer $server, array $context)
    {
		// [service, method, rawData]
    }
	
    public function afterExecute(Event $event, AbstractServer $server, array $context)
    {
		// [service, method, rawData]
    }
		
    public function beforeDispatch(Event $event, AbstractServer $server, array $context)
    {
		// [service, method, request]
	}

    public function afterDispatch(Event $event, AbstractServer $server, array $context)
    {
		// [service, method, request, response]
    }
}