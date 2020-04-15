namespace {{rootNs}}\Auth;
use PhalconPlus\Auth\Model as AuthModel;
use PhalconPlus\Auth\UserProvider;

class Model extends AuthModel
{
    public function __construct(UserProvider $user)
    {
        parent::__construct($user);
        $this->policies = [
        ];
    }

}