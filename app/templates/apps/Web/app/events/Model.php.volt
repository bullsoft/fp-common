namespace {{rootNs}}\Events;

use PhalconPlus\Contracts\EventAttachable;
use Ph\{
    EventsManager,
    ModelsManager,
    Di,
};

use {{rootNs}}\Auth\Model as AuthModel;

class Model implements EventAttachable
{
    public function __construct()
    {
        ModelsManager::setEventsManager(Di::get('eventsManager'));
    }

    public function attach($param = null)
    {
        if(Di::has('user')) {
            $user = Di::get('user');
            EventsManager::attach("model", new AuthModel($user));      
        }
    }
}