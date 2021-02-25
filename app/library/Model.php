<?php
namespace PhalconPlus\DevTools\Library;
use PhalconPlus\App\Module\ModuleDef;
use PhalconPlus\Enum\Sys;
use Laminas\Code\Generator\ClassGenerator;
use Laminas\Code\Reflection\ClassReflection;
use Laminas\Code\Generator\FileGenerator;
use Laminas\Code\Generator\DocBlockGenerator;
use Ph\{Di, Config};

class Model
{
    protected $def = null;
    protected $dir = "";
    protected $dbService = "";
    protected $dbName = "";

    public function __construct(ModuleDef $def, string $dbService = "")
    {
        $this->def = $def;
        $this->dir = $def->getDir().'/src/models';
        if(!empty($dbService)) {
            $this->dbService = $dbService;
            $this->dbName = $def->config()->path("{$dbService}.dbname");
        }
    }

    public function getNamespace(bool $dbAsNamespace = false)
    {
        $namespace = $this->def->config()->path("application.ns");
        $modelNs = rtrim($namespace, '\\');
        $modelNs .= "\\Models";
        if($dbAsNamespace == true && !empty($this->dbName)) {
            $dbName = \Phalcon\Text::camelize($this->dbName);
            $modelNs .= '\\' . $dbName;
        }
        return $modelNs;
    }

    public function generateBaseModel(bool $dbAsNamespace = false) : Model
    {
        $modelDir = $this->getDir($dbAsNamespace);
        // 如果models目录不存在，则创建它
        if(!is_dir($modelDir)) {
            mkdir($modelDir, 0777, true);
        }

        $filePath = $this->dir . "/BaseModel.php";
        if(!is_file($filePath)) {
            $tempPath = Sys::getPrimaryModuleDir() . "/app/templates/generator/BaseModel.php.volt";
            $modelBaseTemplate = file_get_contents($tempPath);
            $tokens = [
                "<<<namespace>>>",
            ];
            $replacements = [
                $this->getNamespace(false)
            ];
            $modelBaseClass = str_replace($tokens, $replacements, $modelBaseTemplate);
            file_put_contents($filePath, "<?php\n" . $modelBaseClass);
        }
        return $this;
    }

    public function getDir(bool $dbAsNamespace = false)
    {
        if($dbAsNamespace == true && !empty($this->dbName)) {
            $dbName = \Phalcon\Text::camelize($this->dbName);
            return $this->dir . '/' . $dbName;
        }
        return $this->dir;
    }

    public function generateFromTable(string $table, bool $dbAsNamespace = false) : FileGenerator
    {
        $className = \Phalcon\Text::camelize($table) . "Model";
        $namespace = $this->getNamespace($dbAsNamespace);
        $filePath = $this->getDir($dbAsNamespace) . "/" . $className . Sys::EXT;
        $fullClassName = $namespace . '\\' . $className;
        if (class_exists($fullClassName)) {
            $cr = new ClassReflection(new $fullClassName());
            $generator = ClassGenerator::fromReflection($cr);
            $constants = $generator->getConstants();
            foreach ($constants as $key => $val) {
                if ($cr->getParentClass()->hasConstant($key)) {
                    $generator->removeConstant($key);
                }
            }
            $uses = $generator->getUses();
            foreach($uses as $statement) {
                $generator->addUse($statement['use'], $statement['as']);
            }
        } else {
            $generator = (new ClassGenerator())
                ->setName($className)
                ->setExtendedClass("\\".$this->getNamespace(false)."\\BaseModel");
        }
        // DocBlock
        $docblock = DocBlockGenerator::fromArray(array(
            'shortDescription' => 'Phalcon Model: ' . $className,
            'longDescription'  => '此文件由代码自动生成，代码依赖PhalconPlus和Laminas\Code\Generator',
            'tags' => array(
                array(
                    'name'        => 'namespace',
                    'description' => $namespace,
                ),
                array(
                    'name'        => 'table',
                    'description' => $table,
                ),
            ),
        ));
        $generator->setDocblock($docblock);

        $generator->hasMethod("onConstruct") && $generator->removeMethod("onConstruct");
        $generator->hasMethod("columnMap") && $generator->removeMethod("columnMap");
        $generator->hasMethod("getSource") && $generator->removeMethod("getSource");

        return (new FileGenerator())
                ->setFilename($filePath)
                ->setNamespace($namespace)
                ->setClass($generator);
    }

    public function generateCache(string $service)
    {

    }
}