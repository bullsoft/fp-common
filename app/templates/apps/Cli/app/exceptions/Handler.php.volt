namespace {{rootNs}}\Exceptions;

use Ph\{
    Di, Log, Request, Response, App, AppEngine,
    FlashSession, Dispatcher, Annotations, View
};

class Handler
{
    public static function render(\Throwable $exception)
    {
        // 
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