<?php
namespace App\Com\Protos;
/**
 * 此类由代码自动生成，请不要修改
 */
class ExceptionBase extends \PhalconPlus\Base\Exception
{
    /**
     * 
     * 
     * $info = "letter A is for Amy";
     * 
     * $info = ["letter A is for Amy", ["Amy"]];
     * 
     * $info = ["letter A is for Amy", 
     *          "text" => "字母A代表%s", 
     *          "args" => ["Amy"]
     *         ];
     * 
     */
    public static function throw($info = "", int $code = 1)
    {
        throw new self($info, $code);
    }
}