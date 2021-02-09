namespace {{rootNs}}\Events;

use Phalcon\Cli\Console;
use Phalcon\Cli\Task;
use Phalcon\Events\Event;
use Phalcon\Cli\Dispatcher;
use PhalconPlus\Contracts\EventAttachable;
use Ph\{EventsManager, Log, };

class AppConsole implements EventAttachable
{
    public function __construct()
    {
        // 
    }

    public function attach($param = null)
    {
        EventsManager::attach("console", $this);
    }

    public function boot(Event $event, Console $app)
    {
        // 
        Log::info("console:boot"); 
    }

    public function beforeHandleTask(Event $event, Console $app, Dispatcher $dispatcher)
    {
        // 
        Log::info("console:before handle task"); 
    }

    public function afterHandleTask(Event $event, Console $app, Task $task)
    {
        //
        Log::info("console:after handle task"); 
    }
}