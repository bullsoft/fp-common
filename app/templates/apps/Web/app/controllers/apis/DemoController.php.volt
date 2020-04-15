namespace {{rootNs}}\Controllers\Apis;

class DemoController extends \Phalcon\Mvc\Controller
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