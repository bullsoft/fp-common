namespace {{rootNs}}\Controllers;

use Ph\{Log, App};

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
