namespace {{rootNs}}\Auth\Resources;
use Ph\{Acl, Sys};
use Phalcon\Acl\Component as AclResource;
use PhalconPlus\Contracts\Auth\Access\ResourceAware;
use {{rootNs}}\Controllers\{
    IndexController,
    UserController,
    ErrorController,
};

class Actions implements ResourceAware
{
    protected function addResource($path = "", $namespace = "")
    {
        if(empty($path)) {
            $path = Sys::getPrimaryModuleDir()."/app/controllers";
            $namespace = \supername(__NAMESPACE__, 2) . "\\Controllers\\";
        } else {
            $tmp = basename($path);
            $namespace = $namespace . \ucfirst($tmp) . "\\";
        }
        
        foreach(glob($path."/*") as $filename) {
            if(is_dir($filename)) {
                $this->addResource($filename, $namespace);
            } elseif(is_file($filename)) {
                $className = basename($filename, ".php");
                if($className == 'BaseController' || $className == 'ControllerBase') {
                    continue;
                }
                $classNameWithNs = $namespace.$className;
                $resource = new AclResource($classNameWithNs);
                $methods = get_class_methods($classNameWithNs);
                foreach($methods as $method) {
                    if(substr($method, -6) == 'Action') {
                        Acl::addComponent($resource, $method);
                    }
                }
            }
        }
    }

    public function register()
    {
        $this->addResource();
        return $this;
    }

    public function control()
    {
        // Guests
        Acl::allow('Guests', IndexController::class, 'indexAction');
        Acl::allow('Guests', ErrorController::class, '*');
		
        return $this;
    }
}