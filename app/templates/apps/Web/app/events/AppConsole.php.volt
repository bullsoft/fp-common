namespace {{rootNs}}\Events;

use Phalcon\Cli\Console;
use Phalcon\Cli\Task;
use Phalcon\Events\Event;
use Phalcon\Cli\Dispatcher;
use PhalconPlus\Contracts\EventAttachable;
use Plus\EventsManager;

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
    }

    public function beforeHandleTask(Event $event, Console $app, Dispatcher $dispatcher)
    {
        // 
    }

    public function afterHandleTask(Event $event, Console $app, Task $task)
    {
        // 
    }
}