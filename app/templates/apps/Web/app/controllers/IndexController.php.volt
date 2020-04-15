namespace {{rootNs}}\Controllers;
use Ph\{Log, App};

class IndexController extends BaseController
{
    /**
     * Guests can access
     * @see {{rootNs}}\Auth\Resources\Actions::control()
     */
    public function indexAction()
    {

    }

    /**
     * Guests can't access by default
     */
    public function privateAction()
    {

    }

}
