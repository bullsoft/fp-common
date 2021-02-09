namespace {{rootNs}}\Events;

use Phalcon\Events\Event;
use Phalcon\Http\Response;
use Phalcon\Mvc\Dispatcher;
use Phalcon\Mvc\Application as PhApp;
use Ph\{
    EventsManager, App, Acl, Log,
    Annotations, View, Session, Config, 
    Request, Security, Cookies,
};
use PhalconPlus\Contracts\EventAttachable;

use App\Com\Protos\ExceptionBase as BaseException;

use {{rootNs}}\Auth\User;
use {{rootNs}}\Auth\AclResources;

class AppHandler implements EventAttachable
{
    public function __construct()
    {
        // 
    }

    public function attach($param = null)
    {
        EventsManager::attach("application", $this);
    }

    public function boot(Event $event, PhApp $app)
    {
        Log::info("application:boot");
        (new AclResources())->register();
    }

    public function beforeHandleRequest(Event $event, PhApp $application, Dispatcher $dispatcher)
    {
        Log::info("application:before handler request");
        Session::start();
        if(Request::has('sessionId')) {
            Session::setId(Request::get('sessionId')); 
        }
        // Csrf check
        if(Request::isPost()) {
            if(!Security::checkToken()) {
                BaseException::throw([
                        "Token not given",
                        "text" => "请求未提供Token(%s)",
                        "args" => [Security::getTokenKey()]
                ], 100001);
            }
        }
        // Check Login
        User::checkLogin();
        // Attach Model Events
        EventProvider::attachModelEvents();

        $controller = $dispatcher->getControllerClass();
        $method = $dispatcher->getActiveMethod();
        try {
            // Action注解分析
            $anno = Annotations::getMethod($controller, $method);
            // 禁止模板
            if($anno->has('disableView') || $anno->has('api')) {
                View::disable();
            }
            if($anno->has('disableGuests')) {
                Acl::deny("Guests", $controller, $method);
            } else if($anno->has('allowGuests')) {
                Acl::allow("Guests", $controller, $method);
            }
        } catch(\Exception $e) {
            Log::warning($e->getMessage());
        }
    }

    public function beforeSendResponse(Event $event, PhApp $application, Response $response)
    {
        Log::info("application:before send response");
        $response->setHeader("X-CSRF-TOKEN", Security::getTokenKey() .','. Security::getToken());
        $crypted = App::crypt()->encryptBase64(Security::getToken(), null, true);
        $tokenName = Config::path('application.cookie.token_name');
        Cookies::set($tokenName, $crypted);
    }

}