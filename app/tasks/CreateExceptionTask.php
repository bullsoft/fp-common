<?php
namespace PhalconPlus\DevTools\Tasks;
use Ph\{App, Sys};
class CreateExceptionTask extends BaseTask
{
    public function mainAction()
    {
        $this->cli->info('现在开始引导您创建Phalcon+异常类 ...');
        $that = $this;

        // ------ 选择模块 -------
        $modueList = $this->module->getList();
        $options = array_keys($modueList);
        $input = $this->cli->radio('<green><bold>Step 1 </bold></green>请选择模块:', $options);
        do {
            $module = $input->prompt();
        } while(empty($module));
        if($module == 'common') {
            $path = "/common/protos/Exceptions";
            $ns = "App\\Com\\Protos\\Exceptions";
        } else {
            $path = "/{$module}/app/exceptions";
            $m = App::dependModule($module);
            $ns = rtrim($m->config()->path("application.ns"), "\\") . "\\Exceptions";
        }
        $this->cli->info("<green><bold>Step 2 </bold></green> 开始为{$module}生成异常类...");
        $this->generate($path, $ns);
    }

    public function generate(string $path, string $ns)
    {
        // 异常类名
        $enumExceptionClass = $ns . "\\EnumExceptionCode";

        $enumExceptionCode = $enumExceptionClass::validValues(true);
        $exceptionNS = $enumExceptionClass::exceptionClassPrefix();

        $dir = Sys::getRootDir() . $path;
        if(!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }
        $tempPath =  Sys::getPrimaryModuleDir()."/app/templates/exceptions";
        $volt = App::volt($tempPath);
        // 异常类的父类
        $parentClass = "\App\Com\Protos\ExceptionBase";
        if (!class_exists($parentClass)) {
            $parentClass = "\PhalconPlus\Base\Exception";
        }

        $padding = $this->cli->padding(18);
        foreach ($enumExceptionCode as $className => $code) {
            $replacement = [];
            $replacement["ns"] = $ns;
            $replacement["namespace"] = rtrim($exceptionNS, "\\");
            $replacement["className"] = \Phalcon\Text::camelize($className) . "Exception";
            $replacement["parentClassName"] = $parentClass;
            $replacement["code"] = $code;

            $eCode = new $enumExceptionClass($code);
            $replacement["message"] = var_export($eCode->getMessage()?:"未知错误", true);
            $replacement["level"] = $eCode->getLevel();

            $filePath = $dir . "/". $replacement["className"] . ".php";

            ob_start();
            $volt->render($tempPath."/default.php.volt", $replacement, true);
            $class = "<?php\n".$volt->getContent();
            ob_end_clean();

            $padding->label("  ". $className)->result($filePath);

            file_put_contents($filePath, $class);
        }

        $this->filesystem->deleteDir("/common/var/cache/compiled");

        $this->cli->info(" ... 恭喜，创建成功！");
    }
}
