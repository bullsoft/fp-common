namespace {{rootNs}}\Controllers;

use Plus\{Log, App};

class UserController extends BaseController
{
    
    /**
     * @allowGuests
     *
     */
    public function loginAction()
    {
        echo "请登录！";
        return ;
    }

}
