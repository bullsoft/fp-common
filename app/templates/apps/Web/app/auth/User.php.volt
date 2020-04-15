namespace {{rootNs}}\Auth;

use Phalcon\Mvc\Model;
use PhalconPlus\Contracts\Auth\{
    Access\Authorizable
};
use PhalconPlus\Auth\UserProvider;
use {{rootNs}}\Models\UserModel;
use {{rootNs}}\Auth\Model as AuthModel;
use Ph\{
    Config, Session, Acl, Di, Security, Cookies,
};
use App\Com\Protos\ExceptionBase as BaseException;
use {{rootNs}}\Exceptions\UserNotExistsException;
use {{rootNs}}\Protos\Schemas\RegInfo;

class User extends UserProvider implements Authorizable
{
    const SESSNAME_PATH = "application.cookie.session_name";

    public static function getById(string $userId) : UserProvider
    {
        if ($userId == 0 || empty($userId)) {
            return User::guest();
        }
        $model = UserModel::findFirstById((int) $userId);
        if ($model !== false) {
            return new User($model);
        } else {
            return User::guest();
        }
    }

    // public static function getByToken(string $token) : UserProvider
    // {
        
    // }

    public function hasAccess(string $roleName) : bool
    {
        $roles = Config::path('application.roles')->toArray();
        return $roleName == $this->getRole() || 
                in_array($roleName, $roles[$this->getRole()], true);
    }

    public function isSuper()
    {
        return $this->getRole() == 'Super';
    }

    public function isGuest()
    {
        return $this->getRole() == 'Guests';
    }

    public function isMember()
    {
        return $this->getRole() == 'Members';
    }

    public function isAdmin()
    {
        return $this->getRole() == 'Admin';
    }

    public static function loginByCredentials(array $credentials) : UserProvider
    {
        $cookieName = Config::path(User::SESSNAME_PATH);

        $model = User::getByCredentials($credentials);
        if(User::validateCredentials($model, $credentials)) {
            Cookies::set("login_time", time());
            Session::set($cookieName, $model->id);
            return new User($model);
        }
        // To protect against timing attacks.
        Security::hash(rand());
        throw new UserNotExistsException([
            "user password not matched",
            "text" => "用户名(%s)和密码(%s)不匹配",
            "args" => $credentials,
        ]);
    }

    public static function getByCredentials(array $credentials) : Model
    {
        $model = UserModel::findFirst([
            "username = :m1: OR mobile = :m2:",
            "bind" => [
                "m1" => $credentials['username'],
                "m2" => $credentials['username'],
            ]
        ]);
        if(false == $model) {
            BaseException::throw([
                "User not exists: " . json_encode($credentials),
                "message" => "用户不存在",
            ], 10002);
        }
        return $model;
    }

    public static function register($info) : User
    {
        $regInfo = RegInfo::newInstance((object)$info);
        $lastName  = $info["lastName"];
        $firstName = $info["firstName"];
        if (empty($regInfo->getNickname())) {
            $regInfo->setNickname($lastName? $lastName." ".$firstName : $firstName);
        }
        $model = UserModel::createOne($regInfo);

        $cookieName = Config::path(User::SESSNAME_PATH);
        Session::set($cookieName, $model->id);

        $user = new User($model);

        Di::setShared("user", $user);
        return $user;
    }

    public static function validateCredentials(Model $user, array $credentials) : bool
    {
        return User::checkPassword($credentials['passwd'], $user->passwd, $user->salt);
    }

    public static function checkLogin() : bool
    {
        $cookieName = Config::path(User::SESSNAME_PATH);
        if(Session::has($cookieName)) {
            $userId = intval(Session::get($cookieName));
        } else {
            $userId = 0;
        }
        $user = User::getById($userId);
        Di::setShared("user", $user);
        if($user->isGuest()) {
            Session::remove($cookieName);
            return false;
        }
        return true;
    }

    public static function logout()
    {
        Session::destroy();
    }

    public static function checkLoginWithToken() : bool
    {
        return false;
    }

    public function can(string $ability, $param) : bool
    {
        if(is_string($param)) {
            return Acl::isAllowed($this->getRole(), $param, $ability);
        } elseif (is_object($param) && $param instanceof Model) { 
            $authModel = new AuthModel($this);
            $policy = $authModel->getPolicy($param);
            return $policy->{$ability}($this, $param);
        }
        return false;
    }
}