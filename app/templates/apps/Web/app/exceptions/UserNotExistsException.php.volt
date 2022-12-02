namespace {{rootNs}}\Exceptions;
use App\Com\Protos\ExceptionBase;

/**
 * 此类由代码自动生成，请不要修改
 */
class UserNotExistsException extends ExceptionBase
{
    protected $code = 20001;
    protected $message = '用户(%s)不存在，请核实后再试';
    protected $level = 6;
}