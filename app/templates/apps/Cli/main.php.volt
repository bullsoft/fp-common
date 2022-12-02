date_default_timezone_set('Asia/Shanghai');
ini_set("memory_limit", "4G");

use PhalconPlus\Bootstrap;
use PhalconPlus\Enum\RunMode;
use Phalcon\Support\Version;

$app = (new Bootstrap(__DIR__, "", RunMode::CLI))->app();

$version = (new Version())->getPart(
    Version::VERSION_MAJOR
);

$arguments = [];

foreach($argv as $k => $arg) {
    if($k == 1) {
        $arguments['task'] = $arg;
    } elseif($k == 2) {
        $arguments['action'] = $arg;
    } elseif($k >= 3) {
        $arguments['params'][] = $arg;
    }
}

$app->handle($arguments);