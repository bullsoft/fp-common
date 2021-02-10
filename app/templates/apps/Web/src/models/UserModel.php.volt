namespace {{rootNs}}\Models;

use App\Com\Protos\Exceptions\SystemBusyException;

use {{rootNs}}\Auth\User as AuthUser;
use {{rootNs}}\Exceptions\UserNotExistsException;
use {{rootNs}}\Protos\Enums\UserStatus;
use {{rootNs}}\Protos\Schemas\RegInfo;

use {{rootNs}}\Exceptions\UserAlreadyExistsException;
/**
 * Phalcon Model: UserModel
 *
 * 此文件由代码自动生成，代码依赖PhalconPlus和Laminas\Code\Generator
 *
 * @namespace LightCloud\Uc\Models
 * @table user
 */
class UserModel extends \PhalconPlus\Base\Model
{

    /**
     * @Type bigint(20) unsigned
     * @Null NO
     * @Default
     * @Key PRI
     * @Extra auto_increment
     */
    public $id = null;

    /**
     * @Type varchar(63)
     * @Null NO
     * @Default
     * @Key UNI
     * @Extra
     */
    public $username = '';

    /**
     * @Type varchar(63)
     * @Null YES
     * @Default
     * @Key UNI
     * @Extra
     */
    public $mobile = null;

    /**
     * @Type varchar(256)
     * @Null NO
     * @Default
     * @Key
     * @Extra
     */
    public $salt = '';

    /**
     * @Type varchar(256)
     * @Null NO
     * @Default
     * @Key
     * @Extra
     */
    public $passwd = '';

    /**
     * @Type varchar(63)
     * @Null YES
     * @Default
     * @Key UNI
     * @Extra
     */
    public $email = '';

    /**
     * @Type tinyint(4)
     * @Null YES
     * @Default
     * @Key
     * @Extra
     */
    public $is_email_verified = '0';

    /**
     * @Type varchar(63)
     * @Null YES
     * @Default
     * @Key
     * @Extra
     */
    public $nickname = '';

    /**
     * @Type bigint(20)
     * @Null YES
     * @Default
     * @Key
     * @Extra
     */
    public $invite_user_id = '0';

    /**
     * @Type varchar(63)
     * @Null YES
     * @Default
     * @Key UNI
     * @Extra
     */
    public $invite_code = '';

    /**
     * @Type tinyint(4)
     * @Null NO
     * @Default
     * @Key
     * @Extra
     */
    public $status = '0';

    /**
     * @Type datetime
     * @Null NO
     * @Default
     * @Key
     * @Extra
     */
    public $reg_time = null;

    /**
     * @Type datetime
     * @Null NO
     * @Default
     * @Key
     * @Extra
     */
    public $ctime = null;

    /**
     * @Type datetime
     * @Null NO
     * @Default
     * @Key
     * @Extra on update CURRENT_TIMESTAMP
     */
    public $mtime = null;

    public function initialize()
    {
        parent::initialize();
        $this->setSource("user");
        $this->setWriteConnectionService("db");
        $this->setReadConnectionService("dbRead");
    }

    public static function createOne(RegInfo $regInfo)
    {
        // UserModel
        $user = new self();
        if($regInfo->getMobile()) {
            $user->mobile = $regInfo->getMobile();
            $user->setUniqueKeys(["mobile"]);
            // 是否已经被占用
            if ($user->exists() != false) {
                throw new UserAlreadyExistsException(["mobile alreay exists", $regInfo->getMobile()]);
            }
        }
        if($regInfo->getEmail()) {
            $user->email = $regInfo->getEmail();
            $user->setUniqueKeys(["email"]);
            // 是否已经被占用
            if ($user->exists() != false) {
                throw new UserAlreadyExistsException(["email alreay exists", $regInfo->getEmail()]);
            }
        }
        if($regInfo->getNickname()) {
            $user->nickname = $regInfo->getNickname();
        }
        $user->username = $regInfo->getUsername();
        if(!in_array($user->username, ["m".$user->mobile, $user->email])) {
            $user->setUniqueKeys(["username"]);
            // 是否已经被占用
            if ($user->exists() != false) {
                throw new UserAlreadyExistsException(["username alreay exists", $regInfo->getUsername()]);
            }
        }
        // 生成安全密码
        $sec = AuthUser::hashPassword($regInfo->getPasswd(), true);  
        $user->salt = $sec['salt'];
        $user->passwd = $sec['encrypted'];

        // 默认需要验证
        $user->status = UserStatus::NEED_VALID;
        $user->regTime = date("Y-m-d H:i:s");
        $user->inviteCode = new \Phalcon\Db\RawValue("NULL");

        if ($user->save() == false) {
            throw new SystemBusyException(["failed to create user, userInfo: ", $user->toArray()]);
        }

        return $user;
    }

    public static function activate($userId, $mail)
    {
        $user = UserModel::findFirst([
            "id=:id: AND email=:m:",
            "bind" => [
                "id" => $userId,
                "m" => $mail,
            ]
        ]);
        if($user == false) {
            throw new UserNotExistsException(["activated failed with wrong params", $mail, $userId]);
        }
        $user->status = UserStatus::NORMAL;
        $user->isEmailVerified = 1;
        if($user->save()) {
            return true;
        }
        return false;
    }

    public static function changePasswd($userId, $passwd)
    {
        $user = UserModel::findFirst($userId);
        if($user == false) {
            throw new UserNotExistsException([
                "changePasswd failed with wrong params", 
                $userId
            ]);
        }
        $sec = AuthUser::hashPassword($passwd, true);
        $user->passwd = $sec['encrypted'];
        $user->salt = $sec['salt'];

        if($user->save()) {
            return true;
        }
        return false;
    }

    /**
     * When an instance created, it would be executed
     */
    public function onConstruct()
    {
        $this->id = NULL;
        $this->username = '';
        $this->mobile = NULL;
        $this->salt = '';
        $this->passwd = '';
        $this->email = '';
        $this->isEmailVerified = '0';
        $this->nickname = '';
        $this->inviteUserId = '0';
        $this->inviteCode = '';
        $this->status = '0';
        $this->regTime = NULL;
        $this->ctime = NULL;
        $this->mtime = NULL;
    }

    /**
     * Column map for database fields and model properties
     */
    public function columnMap()
    {
        return [
            'id' => 'id', 
            'username' => 'username', 
            'mobile' => 'mobile', 
            'salt' => 'salt', 
            'passwd' => 'passwd', 
            'email' => 'email', 
            'is_email_verified' => 'isEmailVerified', 
            'nickname' => 'nickname', 
            'invite_user_id' => 'inviteUserId', 
            'invite_code' => 'inviteCode', 
            'status' => 'status', 
            'reg_time' => 'regTime', 
            'ctime' => 'ctime', 
            'mtime' => 'mtime', 
        ];
    }
}

