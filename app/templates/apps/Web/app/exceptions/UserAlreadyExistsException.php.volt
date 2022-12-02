namespace {{rootNs}}\Exceptions;
use App\Com\Protos\ExceptionBase;

/**
 * 此类由代码自动生成，请不要修改
 */
class UserAlreadyExistsException extends ExceptionBase
{
    protected $code = 20004;
    protected $message = '用户资料(%s)已存在';
    protected $level = 6;
}