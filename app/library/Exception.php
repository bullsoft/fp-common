<?php
namespace PhalconPlus\DevTools\Library;
use PhalconPlus\App\Module\ModuleDef;

class Exception
{
    protected $def;
    public function __construct(ModuleDef $def)
    {
        $this->def = $def;
    }

    public function generate()
    {
        
    }
}