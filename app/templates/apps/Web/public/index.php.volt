use PhalconPlus\Bootstrap;
use {{rootNs}}\Exceptions\Handler as ExceptionHandler;

try {
    $app = (new Bootstrap(dirname(__DIR__)))->app();
    $response = $app->handle($_SERVER['REQUEST_URI']);
} catch(Throwable $e) {
    ExceptionHandler::catch($e);
    if(isset($app)) {
        $response = $app->response();
    } else {
        throw $e;
    }
}
$response->send();
$app->terminate();
