namespace {{rootNs}}\Exceptions;

use Ph\{
    Di, Log, Request, Response, App, AppEngine,
    FlashSession, Dispatcher, Annotations, View
};

class Handler
{
    public static function render(\Throwable $exception)
    {
        $ctrClassName = Dispatcher::getControllerClass();
        $method = Dispatcher::getActiveMethod();
        $anno = Annotations::getMethod($ctrClassName, $method);

        $errorMsg = $msg = $exception->getMessage();

        if($anno->has('api') || Request::getBestAccept() == 'application/json') {
            $data = new \stdClass();
            if(($offset = \strpos($msg, "__DATA__")) !== false) {
                $errorMsg = \substr($msg, 0, $offset);
                $dataMsg = substr($msg, $offset+\strlen("__DATA__"));
                $data = json_decode($dataMsg, true);
            }
            $error = array(
                'errorCode' => max(1, $exception->getCode()),
                'errorMsg' => $errorMsg,
                'data' => $data??(new \stdClass()),
                'sessionId' => '',
            );
            Response::setContentType("application/json", "UTF-8");
            Response::setJsonContent($error, \JSON_UNESCAPED_UNICODE);   
        } else {
            if(Request::isPost()) {
                FlashSession::error($exception->getMessage());
                Response::redirect(Request::getHTTPReferer());
            } else {
                $content = AppEngine::request("error", "show500", [
                    $exception
                ]);
                Response::setContent($content);
            }
        }
    }

    public static function report(\Throwable $exception)
    {
        Log::error(
            $exception->__toString()
        );
    }

    public static function catch(\Throwable $exception)
    {
        self::report($exception);
        self::render($exception);
    }
}