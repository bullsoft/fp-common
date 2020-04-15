namespace {{rootNs}}\Events;

use PhalconPlus\App\Module\AbstractModule as AppModule;
use PhalconPlus\Contracts\EventAttachable;

class EventProvider implements EventAttachable
{
    protected $module = null;

    protected $events = [
        // 
    ];

    public function __construct(AppModule $module)
    {
        $this->module = $module;
    }

    public function attach($param = null)
    {
        (new SuperApp())->attach();
        (new AppConsole())->attach();
        (new Db())->attach();
    }

    public static function attachModelEvents()
    {
        //
    }
}