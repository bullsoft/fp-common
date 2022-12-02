use PhalconPlus\Bootstrap;
use {{rootNs}}\Exceptions\Handler as ExceptionHandler;
use GuzzleHttp\Psr7\ServerRequest;

try {
    $app = (new Bootstrap(dirname(__DIR__)))->app();
    $serverRequest = ServerRequest::fromGlobals();
    $response = $app->handle($serverRequest);
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
