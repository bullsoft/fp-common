use PhalconPlus\Enum\RunMode;
use PhalconPlus\Bootstrap;
use {{rootNs}}\Exceptions\Handler as ExceptionHandler;

try {
    $app = (new Bootstrap(dirname(__DIR__), '', RunMode::SRV))->app();
    $response = $app->handle($_SERVER['REQUEST_URI']);
} catch(Throwable $e) {
    ExceptionHandler::catch($e);
    $response = $app->di()->get("response");
}
$response->send();