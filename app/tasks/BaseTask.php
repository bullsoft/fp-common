<?php
namespace PhalconPlus\DevTools\Tasks;
use League\Flysystem\Filesystem;
use League\Flysystem\Adapter\Local as LocalAdapter;
use PhalconPlus\Enum\Sys;
use PhalconPlus\DevTools\Library\Module;
use Ph\{
    App, Di,
};

class BaseTask extends \Phalcon\CLI\Task
{
    public $filesystem;
    public $module;

    public function initialize()
    {
        $this->filesystem = new Filesystem(new LocalAdapter(Sys::getRootDir()));
        $this->module = new Module($this->filesystem);
    }
}