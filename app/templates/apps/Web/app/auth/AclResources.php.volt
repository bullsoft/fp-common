namespace {{rootNs}}\Auth;
use Phalcon\Acl\Role;
use Ph\{Config, Acl};
use {{rootNs}}\Exceptions\Handler as ExceptionHandler;
use {{rootNs}}\Auth\Resources\{
    Actions, Models
};

class AclResources
{
    public function __construct()
    {
        foreach(Config::path('application.roles') as $role => $inheritList) {
            Acl::addRole(new Role($role));
            foreach($inheritList as $roleToInherit) {
                Acl::addInherit($role, $roleToInherit);
            }
        }    
    }

    public function register()
    {
        try {
            (new Actions())->register()->control();
            (new Models())->register()->control();
        } catch(\Exception $e) {
            ExceptionHandler::catch($e);
            throw $e;   
        }
    }
}