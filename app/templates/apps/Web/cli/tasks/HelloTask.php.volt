namespace {{rootNs}}\Tasks;
use Phalcon\Cli\Task;
use Ph\{App, };

class HelloTask extends Task
{
    public function mainAction()
    {
        echo "You are in module: " . App::getDefaultModule() . PHP_EOL;
    }
}