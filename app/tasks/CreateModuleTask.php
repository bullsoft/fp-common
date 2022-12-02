<?php
namespace PhalconPlus\DevTools\Tasks;
use Ph\{Di, App};
use PhalconPlus\Enum\Sys;
use PhalconPlus\Enum\RunMode;
use League\Flysystem\Filesystem;
use League\Flysystem\Adapter\Local as LocalAdapter;

class CreateModuleTask extends BaseTask
{
    public function mainAction()
    {
        $this->cli->info('现在开始引导您创建Phalcon+模块 ...');
        $that = $this;

        // ------ 获取模块的名字 -------
        $input = $this->cli->input("<green><bold>Step 1 </bold></green>请输入该模块的名称，如\"api\"" . PHP_EOL. "[Enter]:");
        $input->accept(function($response) use ($that){
            $filesystem = $that->filesystem;
            if ($filesystem->has($response)) {
                $that->cli->backgroundRed("模块{$response}已经存在，请更换名称再试！");
                return false;
            }
            return !empty($response);
        });
        $name = $input->prompt();

        // ------ 获取项目命名空间 -------
        $input = $this->cli->input("<green><bold>Step 2 </bold></green>请输入该模块的根命名空间，如'UserCenter'" . PHP_EOL. "[Enter]:");
        $input->accept(function($response) {
            return !empty($response);
        });
        $ns = $input->prompt();

        // ------ 获取模块的运行模式 -------
        $options = RunMode::validValues();
        $input    = $this->cli->radio('<green><bold>Step 3 </bold></green>请选择' . $name . '模块的运行模式:', $options);
        do{
            $mode = $input->prompt();
        }while(empty($mode));

        // --------- 输入总结 -----------
        $this->cli->br()->info("您的输入如下：");
        $padding = $this->cli->padding(10);
        $padding->label('  命名空间')->result($ns);
        $padding->label('  模块名字')->result($name);
        $padding->label('  运行模式')->result($mode);

        // --------- 继续？ ---------------
        $input = $this->cli->confirm('请确认以上信息，继续?');
        // Continue? [y/n]
        if (!$input->confirmed()) {
            // Do your thing here
            $this->cli->info("... ByeBye");
            exit(1);
        }
        $this->cli->info(" ... 开始为你生成模块 ...")->br();
        $this->generate($name, $ns, $mode);
    }

    private function generate($module, $ns, $mode)
    {
        $progress = $this->cli->progress()->total(100);

        $tempPath =  Sys::getPrimaryModuleDir()."/app/templates/apps";
        $filesystem = new Filesystem(new LocalAdapter($tempPath));

        $cachePath = '/common/var/cache';
        if(!$this->filesystem->has($cachePath."/{$mode}")) {
            $this->filesystem->createDir($cachePath."/{$mode}");
        }

        $volt = App::volt($tempPath);
        $params = [
            "rootNs" => $ns,
            "module" => $module,
            "mode"   => $mode,
            "moduleName" => App::helper()->camelize($module),
            "port"   => mt_rand(8000, 9000),
            "secKey" => App::security()->getRandom()->base64Safe(18),
        ];

        $progress->advance(20, "=");

        $list = $filesystem->listContents("/{$mode}", true);

        foreach($list as $item) {
            if($item['type'] == 'dir') {
                $path = $cachePath."/{$item['path']}";
                if(!$this->filesystem->has($path)) {
                    $this->filesystem->createDir($path);
                }
            } elseif($item['type'] == 'file' && $item['extension'] == 'volt') {
                $source = $tempPath."/{$item['path']}";
                $target = $cachePath."/{$item['dirname']}/{$item['filename']}";
                if(substr($target, -3) == "php") {
                    ob_start();
                    $volt->render($source, $params, true);
                    $content = "<?php\n".$volt->getContent();
                    ob_end_clean();
                } else {
                    $content = $filesystem->read("/{$item['path']}");
                }
                $this->filesystem->write($target, $content);
            }
        }
        
        // 假装在做事情
        usleep(150000);
        $progress->advance(30, "=");
        // 假装在做事情
        usleep(50000);
        $progress->advance(10, "=");
        // 假装在做事情
        usleep(100000);
        $progress->advance(20, "=");

        $this->filesystem->deleteDir($cachePath."/compiled");
        $this->filesystem->rename(
            $cachePath."/{$mode}", 
            "/{$module}"
        );

        // 假装在做事情
        usleep(200000);
        $progress->advance(20, "");
        $this->cli->br()->info("... 恭喜，模块{$module}创建成功！");
    }


    public function helpAction()
    {
        echo "to do..." . PHP_EOL;
    }
}