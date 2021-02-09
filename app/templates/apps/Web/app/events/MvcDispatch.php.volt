namespace {{rootNs}}\Events;

use Phalcon\Events\Event;
use Phalcon\Mvc\DispatcherInterface;
use Phalcon\Mvc\Dispatcher;
use Ph\{
    EventsManager,    
    Dispatcher as PhDispatcher,
    Di, Acl, Request, Response, Session, Annotations,
};
use PhalconPlus\Contracts\{
    EventAttachable,
    Auth\Access\DispatchEvent,
};
use App\Com\Protos\ExceptionBase as BaseException;

class MvcDispatch implements EventAttachable, DispatchEvent
{
    public function __construct()
    {
        PhDispatcher::setEventsManager(Di::get('eventsManager'));
    }

    public function attach($param = null)
    {
        EventsManager::attach("dispatch", $this);
    }

    public function beforeDispatchLoop(Event $event, DispatcherInterface $dispatcher)
    {
        // $controller = $dispatcher->getControllerName();
        // $action = $dispatcher->getActionName();

        return true;
    }

    public function beforeExecuteRoute(Event $event, DispatcherInterface $dispatcher) : bool
    {
        // API 直接放行
        if(rtrim($dispatcher->getNamespaceName(), "\\") == "{{rootNs}}\\Controllers\\Apis") {
            return true;
        }

        $controller = $dispatcher->getActiveController();
        $ctrClassName = $dispatcher->getControllerClass();
        $method = $dispatcher->getActiveMethod();

        // Action注解分析
        $anno = Annotations::getMethod($ctrClassName, $method);

        $user = Di::get('user');

        if(!Acl::isAllowed($user->getRole(), $ctrClassName, $method)) {
            if($user->isGuest()) {
				$from = urlencode(Request::getURI());
                Response::redirect('/user/login?from='.$from);
            } else {
                if($anno->has('api')) {
                    BaseException::throw('您没有权限');
                } else {
                    $dispatcher->forward(array(
                        'controller' => 'error',
                        'action'     => 'show403'
                    ));
                }
            }
            return false;
        }

        if(method_exists($controller, 'setUser')) {
            $controller->setUser($user);
        } 

        return true;
    }

    public function afterExecuteRoute(Event $event, DispatcherInterface $dispatcher)
    {
        $returnValue = $dispatcher->getReturnedValue();
        if(is_object($returnValue) && ($returnValue instanceof \Phalcon\Http\Response)) {
            return true;
        }
        if(!is_array($returnValue) && !is_object($returnValue)) {
            return true;
        }
        $return = [
            'errorCode' => 0,
            'data' => $returnValue,
            'errorMsg' => '',
            'sessionId' => Session::getId(),
        ];
        Response::setContentType("application/json", "UTF-8");
        Response::setJsonContent($return, \JSON_UNESCAPED_UNICODE);
        $dispatcher->setReturnedValue(Response::itself());
        return true;
    }

    public function beforeForward(Event $event, DispatcherInterface $dispatcher, array $forward)
    {
        $dispatcher->setNamespaceName("{{rootNs}}\\Controllers\\");
    }

    public function beforeException(Event $event, DispatcherInterface $dispatcher, \Exception $exception)
    {
        if(rtrim($dispatcher->getNamespaceName(), "\\") == "{{rootNs}}\\Controllers\\Apis") {
            throw $exception;
        }

        // if($version < 4) {
        //     $exceptionClass = \Phalcon\Mvc\Dispatcher::class;
        // } else {
        //     $exceptionClass = \Phalcon\Dispatcher\Exception::class;
        // }
        switch ($exception->getCode()) {
            case Dispatcher\Exception::EXCEPTION_HANDLER_NOT_FOUND:
            case Dispatcher\Exception::EXCEPTION_ACTION_NOT_FOUND:
                $dispatcher->forward(array(
                    'controller' => 'error',
                    'action'     => 'show404'
                ));
                return false;
            default:
                throw $exception;
                return false;
        }
    }
}