namespace {{rootNs}}\Controllers;

use Ph\{
    Acl, Dispatcher,
};
use {{rootNs}}\Auth\User;

class BaseController extends \Phalcon\Mvc\Controller
{
    protected $controller;
    protected $action;
    public    $user = null;
    
    public function initialize()
    {
        $this->controller = $this->dispatcher->getControllerName();
        $this->action = $this->dispatcher->getActionName();

        $title = "页面标题(" . $this->controller . ":" . $this->action . ")";
        $this->view->setVar("controller", $this->controller);
        $this->view->setVar("action", $this->action);
        $this->view->setVar("user", $this->user);
        $this->view->setVar("title", $title);
        $this->view->setVar("headDesc",     "headDesc:网站描述");
        $this->view->setVar("headKeywords", "headKeywords:网站关键词");
        $this->view->setVar("ver", date("YmdHis").rand(100000, 999999));

    }

    public function setUser(User $user)
    {
        $this->user = $user;
    }

    public function getUser()
    {
        return $this->user;
    }

    public function authroize()
    {
        $controller = Dispatcher::getControllerClass();
        $method = Dispatcher::getActiveMethod();
        return Acl::isAllowed($this->user->getRole(), $controller, $method);
    }
}