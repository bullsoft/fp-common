namespace {{rootNs}}\Controllers\Apis;
use Phalcon\Mvc\Controller as PhController;

class DemoController extends PhController
{
    /**
     * @api
     */
    public function indexAction()
    {
        return [
            "foo" => "bar"
        ];
    }
}