<?php
namespace PhalconPlus\DevTools\Tasks;
use League\Flysystem\Filesystem;
use League\Flysystem\Adapter\Local as LocalAdapter;

class CreateModuleTask extends \Phalcon\CLI\Task
{
    protected $modes = [
        "Web" => "Module",
        "Cli" => "Task",
        "Srv" => "Srv",
    ];

    public function mainAction()
    {
        $this->cli->info('现在开始引导您创建Phalcon+模块 ...');
        $that = $this;

        // ------ 获取模块的名字 -------
        $input = $this->cli->input("<green><bold>Step 1 </bold></green>请输入该模块的名称，如\"api\"" . PHP_EOL. "[Enter]:");
        $input->accept(function($response) use ($that){
            $filesystem = new Filesystem(new LocalAdapter(APP_ROOT_DIR));
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
        $modes = $this->modes;
        $options  = array_keys($modes);
        $input    = $this->cli->radio('<green><bold>Step 3 </bold></green>请选择' . $name . '模块的运行模式:', $options);
        do{
            $mode = $input->prompt();
        }while(empty($mode));

        if(!isset($modes[$mode])) {
            $this->cli->backgroundRed("致命错误：运行模式不存在，请重新选择！");
            exit(1);
        }

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

        $modeMap = $this->modes;

        $dirs = [
            "app/config",
            "public"
        ];
        $files = [
            "public/index.php",
            "app/config/dev.php",
            "app/" . $modeMap[$mode] . ".php",
            ".htrouter.php",
        ];

        if($mode == "Web") {
            $dirs[] = "app/controllers";
            $dirs[] = "app/views/index";
            $files[] = "app/controllers/IndexController.php";
            $files[] = "app/controllers/ErrorController.php";
        } elseif ($mode == "Srv") {
            $dirs[] = "app/services";
            $dirs[] = "app/tasks";
            $dirs[] = "app/models";
            $files[] = "app/services/DummyService.php";
            $files[] = "app/tasks/init.php";
        }

        // 假装在做事情
        usleep(1000000);
        $progress->advance(20); // Adds 10 to the current progress

        $filesystem = new Filesystem(new LocalAdapter(APP_ROOT_DIR));

        foreach ($dirs as $dir) {
            $filesystem->createDir($module."/".$dir);
        }

        // 假装在做事情
        usleep(1500000);
        $progress->advance(30); // Adds 10 to the current progress

        $viewPath = "common/app/templates/";
        $cachePath = $viewPath . "compiled/";

        $filesystem->createDir($cachePath);

        $di = $this->getDI();

        usleep(500000);
        $progress->advance(10);

        // 初始化模板
        $view = new \Phalcon\Mvc\View();
        $view->setDI($this->getDI());
        $view->setViewsDir($viewPath);
        $view->registerEngines(array(
            ".volt" => function() use ($view, $di, $cachePath) {
                $volt = new \Phalcon\Mvc\View\Engine\Volt($view, $di);
                $volt->setOptions(array(
                    "compiledPath"      => $cachePath,
                    "compiledExtension" => ".compiled",
                    "compiledAlways"    => false
                ));
                $compiler = $volt->getCompiler();
                $compiler->addExtension(new \PhalconPlus\Volt\Extension\PhpFunction());
                return $volt;
            }
        ));

        // 假装在做事情
        usleep(1000000);
        $progress->advance(20);
        // 生成文件
        foreach ($files as $file) {
            $fileName = basename($file);
            // echo $fileName . PHP_EOL;
            $view->start()
                ->render("generator", $fileName)
                ->finish();

            $view->setVar("rootNs", $ns);

            $view->setVar("module", $module);
            $view->setVar("mode", $mode);
            $view->setVar("moduleName", ucfirst($module));
            $filesystem->write($module."/".$file, "<?php\n".$view->getContent());
        }

        $filesystem->deleteDir($cachePath);

        // 假装在做事情
        usleep(2000000);

        $progress->advance(20);
        $this->cli->br()->info("... 恭喜，模块{$module}创建成功！");
    }


    public function helpAction()
    {
        echo "to do..." . PHP_EOL;
    }
}