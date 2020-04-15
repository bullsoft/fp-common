namespace {{rootNs}}\Events;
use Phalcon\Events\Event;
use PhalconPlus\Contracts\EventAttachable;
use Ph\{
    EventsManager,
    Di, View as PhView,
};

class View implements EventAttachable
{
    public function __construct()
    {
        PhView::setEventsManager(Di::get('eventsManager'));
    }

    public function attach($param = null)
    {
        EventsManager::attach("view", $this);
    }

    public function beforeRender(Event $event, \Phalcon\Mvc\View $view)
    {
        return true;
    }

    public function beforeRenderView(Event $event, \Phalcon\Mvc\View $view, $path = "") 
    {
        return true;
    }

    public function notFoundView(Event $event, \Phalcon\Mvc\View $view, $path = "")
    {
        // 
    }
}