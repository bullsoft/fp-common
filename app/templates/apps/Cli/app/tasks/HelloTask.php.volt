namespace {{rootNs}}\Tasks;
use Ph\{
    App, Log
};
class HelloTask extends \Phalcon\Cli\Task
{
    public function mainAction()
    {
        echo "You are in module: " . App::getDefaultModule() . PHP_EOL;
    }
}