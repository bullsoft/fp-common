<?php
namespace PhalconPlus\DevTools\Library;
use PhalconPlus\App\Module\ModuleDef;

class Database
{
    protected $def;
    public function __construct(ModuleDef $def)
    {
        $this->def = $def;
    }

    public function migration($service)
    {
        
    }
}