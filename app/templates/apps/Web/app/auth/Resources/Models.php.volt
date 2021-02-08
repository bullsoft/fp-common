namespace {{rootNs}}\Auth\Resources;

use Phalcon\Acl\Component as AclResource;
use PhalconPlus\Contracts\Auth\Access\ResourceAware;
use Ph\Acl;
use {{rootNs}}\Models\UserModel;

class Models implements ResourceAware
{
    public function register()
    {   
        foreach(glob(APP_MODULE_DIR."/src/models/*.php") as $filename) {
            $className = basename($filename, ".php");
            if($className == 'BaseModel' || $className == 'ModelBase') {
                continue;
            }
            $classNameWithNs = \supername(__NAMESPACE__, 2) . "\\Models\\" . $className;
            $resource = new AclResource($classNameWithNs);
            Acl::addComponent($resource, [
                'view',
                'list',
                'update',
                'create',
                'delete'
            ]);
        }
        return $this;
    }

    public function control()
    {
        Acl::allow("Guests", UserModel::class, "*");
        return $this;
    }

}