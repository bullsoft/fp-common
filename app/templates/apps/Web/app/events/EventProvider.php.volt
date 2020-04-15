namespace {{rootNs}}\Events;

use PhalconPlus\App\Module\AbstractModule as AppModule;
use PhalconPlus\Contracts\EventAttachable;

class EventProvider implements EventAttachable
{
    protected $module = null;

    protected $events = [
        "superapp"    => SuperApp::class,
        "acl"         => Acl::class,
        "application" => AppHandler::class,
        "dispatch"    => MvcDispatch::class,
        "router"      => Router::class,
        "view"        => View::class,
        "db"          => Db::class,
    ];

    public function __construct(AppModule $module)
    {
        $this->module = $module;
    }

    public function attach($param = null)
    {
        if($this->module->isWeb()) {
            foreach($this->events as $eventClass) {
                $event = new $eventClass();
                $event->attach($param);
            }
        } elseif($this->module->isSrv()){
            (new SuperApp())->attach();
            (new BackendServer())->attach();
        } elseif($this->module->isCli()) {
            (new SuperApp())->attach();
            (new AppConsole())->attach();
        }
    }

    public static function attachModelEvents()
    {
        (new Model())->attach();
    }
}