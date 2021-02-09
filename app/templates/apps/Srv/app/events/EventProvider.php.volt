namespace {{rootNs}}\Events;

use PhalconPlus\App\Module\AbstractModule as AppModule;
use PhalconPlus\Contracts\EventAttachable;

class EventProvider implements EventAttachable
{
    protected $module = null;

    protected $events = [
        "superapp"    => SuperApp::class,
        "db"          => Db::class,
    ];

    public function __construct(AppModule $module)
    {
        $this->module = $module;
    }

    public function attach($param = null)
    {
        foreach($this->events as $eventClass) {
            $event = new $eventClass();
            $event->attach($param);
        }
        if($this->module->isSrv()){
            (new BackendServer())->attach();
        } elseif($this->module->isCli()) {
            (new AppConsole())->attach();
        }
    }

    public static function attachModelEvents()
    {
        (new Model())->attach();
    }
}