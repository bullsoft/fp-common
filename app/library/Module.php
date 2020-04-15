<?php
namespace PhalconPlus\DevTools\Library;
use PhalconPlus\App\Module\ModuleDef;
use League\Flysystem\Filesystem;
use Ph\{App, Sys, };
class Module
{
    protected $filesystem;

    public function __construct(Filesystem $filesystem)
    {
        $this->filesystem = $filesystem;
    }

    public function getList() : array
    {
        $items = $this->filesystem->listContents();
        $list = [];
        foreach($items as $item) {
            if($item['type'] == "dir") {
                $name = $item['basename'];
                if(\Phalcon\Text::startsWith($name, ".")) {
                    continue;
                }
                $def = $this->check($name);
                if($def) {
                    $list[$name] = [];
                    $list[$name]["name"] = $def->config()->path('application.name');
                    $list[$name]["dir"]  = $def->getDir();
                    $list[$name]["def"]  = $def;
                    $list[$name]["pid"]  = $this->getPidPath($def);
                    $list[$name]["create_time"] = date("Y-m-d H:i:s", $item['timestamp']);
                }
            }
        }
        return $list;
    }

    public function check($name) : ?ModuleDef
    {
        if(is_object($name) && $name instanceof ModuleDef) {
            return $name;
        } 
        if(\is_string($name)) {
            $file = $this->filesystem;
            if (!$file->has($name)) {
                return null;
            }
            if (!$file->has("{$name}/app/Srv.php") 
             && !$file->has("{$name}/app/Cli.php")
             && !$file->has("{$name}/app/Web.php") 
             && !$file->has("{$name}/app/Module.php") 
            ) {
                return null;
            }
            if (!$file->has("{$name}/app/config/". App::getEnv() . ".php")
                && !$file->has("{$name}/app/config/config.php")
            ) {
                return null;
            }
            $dir = Sys::getRootDir()."/{$name}";
            return new ModuleDef(App::itself(), $dir);
        }
        return null;
    }

    public function getPidPath($name) : string
    {
        $module = $this->check($name);
        if($module) {
            $dir = $module->getDir()."/var/run";
            if(!\file_exists($dir)) {
                \mkdir($dir, 0777, true);
            }
            return $dir . "/server.pid";
        }
        return "";
    }

    public function getAccessLogPath($name) : string
    {
        $module = $this->check($name);
        if($module) {
            $dir = $module->getDir() . "/var/log";
            if(!\file_exists($dir)) {
                \mkdir($dir, 0777, true);
            }
            return $dir . "/access.log";
        }
        return "";
    }

    public function generate(array $info)
    {

    }

    public function install(string $url, string $name = null)
    {
        // git clone
        // curl download
    }

    public function cleanAll() : void
    {
        $dirs = [
            '/var/log', 
            '/var/cache',
        ];

        if ($this->filesystem->has("build.tar.gz")) {
            $this->filesystem->delete("build.tar.gz");
        }
        
        $list = $this->getList();
        foreach($list as $name => $item) {
            foreach($dirs as $dir) {
                $subList = $this->filesystem->listContents("{$name}{$dir}");
                foreach($subList as $subItem) {
                    if($subItem['type'] == 'file') {
                        $this->filesystem->delete($subItem['path']);
                    } elseif($subItem['type'] == 'dir') {
                        $this->filesystem->deleteDir($subItem['path']);
                    }
                }
            }
        }
    }
}