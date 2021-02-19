namespace {{rootNs}}\Exceptions;
use PhalconPlus\Enum\Exception as EnumException;
use App\Com\Protos\Enums\LoggerLevel;

/** 
 * 建议从一个比较大的数字起，框架占用了 [0, 10000) 以内的异常码
 *
 */
class EnumExceptionCode extends EnumException
{
    const __default = self::UNKNOWN;

    /**
     * 请不要使用重复异常码
     */
    const UNKNOWN = 10000;
   

    protected static $details = [
        self::UNKNOWN => [
            "message" => "未知错误",
            "level" => LoggerLevel::ERROR,
        ],
    ];
   
    public static function exceptionClassPrefix()
    {
        return __NAMESPACE__ . "\\";
    }
}
