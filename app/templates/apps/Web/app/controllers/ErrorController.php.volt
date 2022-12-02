namespace {{rootNs}}\Controllers;
use Plus\Router;

class ErrorController extends BaseController
{
    public function initialize()
    {
    }

    public function show404Action()
    {
        $this->view->setVar("notFoundUrl", Router::getRewriteUri());
    }

    public function show403Action()
    {

    }

    public function show500Action($e = null)
    {
        $e = $e ?? new \Exception("Unknown Exception", 10001);   
        $this->view->setVar("errorCode",    $e->getCode());
        $this->view->setVar("errorMessage", $e->getMessage());
        $this->view->setVar("errorTrace",   $e->getTraceAsString());
    }
}