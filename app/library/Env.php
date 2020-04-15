<?php
namespace PhalconPlus\DevTools\Library;
use PhalconPlus\App\Module\ModuleDef;

class Env
{
    protected $def;
    public function __construct(ModuleDef $def)
    {
        $this->def = $def;
    }
}