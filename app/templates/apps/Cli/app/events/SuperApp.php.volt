namespace {{rootNs}}\Events;

use Phalcon\Events\Event;
use PhalconPlus\App\App as SupApp;
use Ph\{
    EventsManager, App, Di,
};
use PhalconPlus\Contracts\{
    EventAttachable,
};

use {{rootNs}}\Providers\ServiceProvider;

class SuperApp implements EventAttachable
{
    public function __construct()
    {
        App::setEventsManager(Di::get('eventsManager'));
    }

    public function attach($param = null)
    {
        EventsManager::attach("superapp", $this);
    }

    public function beforeExecModule(Event $event, SupApp $app, array $context)
    {
        // $module = $context[0];
        // $params = $context[1];

    }

    public function afterExecModule(Event $event, SupApp $app, array $context)
    {
        // $module = $context[0];
        // $response = $context[1];

        ServiceProvider::destroy($app->di());
    }
}