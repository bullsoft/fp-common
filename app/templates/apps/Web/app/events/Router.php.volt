namespace {{rootNs}}\Events;

use Ph\{
    EventsManager,
    Router as PhRouter, Di,
};
use Phalcon\Events\Event;
use Phalcon\Mvc\Router as MvcRouter;
use Phalcon\Mvc\Router\Route as MvcRoute;
use PhalconPlus\Contracts\{
    EventAttachable,
    Auth\Access\RouterEvent,
};

class Router implements EventAttachable, RouterEvent
{
    public function __construct()
    {
        PhRouter::setEventsManager(Di::get('eventsManager'));
    }

    public function attach($param = null)
    {
        EventsManager::attach("router", $this);
    }

    public function beforeCheckRoute(Event $event, MvcRouter $router, MvcRoute $route)
    {
        // 
    }

    public function afterCheckRoutes(Event $event, MvcRouter $router)
    {
        // 
    }

    
    public function matchedRoute(Event $event, MvcRouter $router, MvcRoute $route)
    {
        // 
    }
}