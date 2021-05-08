<?php
namespace PhalconPlus\DevTools\Tasks;


use Laminas\Code\Generator\DocBlockGenerator;
use Laminas\Code\Generator\PropertyGenerator;
use Laminas\Code\Generator\MethodGenerator;

use PhalconPlus\DevTools\Library\Model;

use Ph\{
    App, Config, Sys,
};

class CreateModelTask extends BaseTask
{

    public function mainAction()
    {
        $this->cli->info('现在开始引导您创建Phalcon+ ORM模型...');
        $that = $this;

        // ------ 获取模块的名字 -------
        $input = $this->cli->input("<green><bold>Step 1 </bold></green>请输入该模块的名称，如\"api\"" . PHP_EOL. "[Enter]:");
        $input->accept(function($response) use ($that){
            $filesystem = $that->filesystem;
            if (!$filesystem->has($response)) {
                $that->cli->backgroundRed("模块{$response}不存在，请更换名称再试！");
                return false;
            }
            return !empty($response);
        });
        $name = $input->prompt();

        // ------ 获取DB连接服务名 -------
        $input = $this->cli->input("<green><bold>Step 2 </bold></green>请输入DI容器中连接DB的服务（具有写权限）的名称，如'db'" . PHP_EOL. "[Enter]:");
        $input->accept(function($response) {
            return !empty($response);
        });
        $dbService = $input->prompt();

        // --------- 是否使用数据库名作为命名空间的一部分？ ---------------
        $useDbAsNamespace = false;
        $input = $this->cli->confirm('<green><bold>Step 3 </bold></green>请确认是否使用数据库名作为模型命名空间的一部分?' . PHP_EOL . "[Enter]:");
        // Continue? [y/n]
        if ($input->confirmed()) {
            $useDbAsNamespace = true;
        }
        // ------ 获取DB名称 -------
        //$input = $this->cli->input("<green><bold>Step 3 </bold></green>请输入数据库名称（如需支持多数据库访问），如：'Acme'" . PHP_EOL. "[Enter]:");
        //$dbName = trim($input->prompt());

        $this->cli->br()->info('正在为您生成代码 ...');

        $this->generate($name, $dbService, $useDbAsNamespace);
    }

    protected function generate($module, $dbService, $useDbAsNamespace)
    {
        // 依赖该模块
        $def = App::dependModule($module)->def();
        $model = (new Model($def, $dbService))
                ->generateBaseModel($useDbAsNamespace);

        $connection = $this->di->get($dbService);
        $tables = $connection->listTables();

        $padding = $this->cli->padding(26);

        foreach($tables as $table) {
            // FileGenerator
            $file = $model->generateFromTable($table, $useDbAsNamespace); 
            // ClassGenerator
            $generator = $file->getClass();
            // Print
            $padding->label($generator->getName())->result($file->getFilename());
            // Columns
            $columns = $connection->describeColumns($table);
            // $indexes = $connection->describeIndexes($table);
            // Body of `onConstruct()` and `columnMap()`
            $onConstructBody = "";
            $columnMapBody = "return [\n";

            foreach($columns as $column) {
                $columnName = $column->getName();
                if(false !== strpos($columnName, "_")) {
                    $camelizeColumnName = lcfirst(\Phalcon\Text::camelize($columnName));
                } else {
                    $camelizeColumnName = $columnName;
                }
                $defaultValue = $this->getDefaultValue($column);
                $columnType = $this->getTypeDesc($column->getType())[0];
                $onConstructBody .= '$this->'.$camelizeColumnName
                                 . ' = ' . $defaultValue
                                 . ";\n";
                $columnMapBody .= "    '{$columnName}' => '{$camelizeColumnName}', \n";
                $property = PropertyGenerator::fromArray(array(
                    'name' => $columnName,
                    'defaultvalue' => null,
                    'flags' => PropertyGenerator::FLAG_PUBLIC,
                    'docblock' => array(
                        'shortDescription' => '',
                        'tags' => array(
                            array(
                                'name' => 'Type',
                                'description' => $columnType,
                            ),
                            array(
                                'name' => 'Primary',
                                'description' => var_export($column->isPrimary(), true),
                            ),
                            array(
                                'name' => 'AutoIncrement',
                                'description' => var_export($column->isAutoIncrement(), true),
                            ),
                            array(
                                'name' => 'Not-Null?',
                                'description' => var_export($column->isNotNull(), true),
                            ),
                            array(
                                'name' => 'Default',
                                'description' => var_export($column->getDefault(), true),
                            ),
                            array(
                                'name' => 'Comment',
                                'description' => var_export($column->getComment(), true),
                            )
                        )
                    ),
                ));
                $generator->removeProperty($columnName);
                $generator->addPropertyFromGenerator($property);
            }
            $columnMapBody .= "];\n";

            // onConstruct()
            $generator->addMethod(
                    'onConstruct',
                    array(),
                    MethodGenerator::FLAG_PUBLIC,
                    $onConstructBody,
                    DocBlockGenerator::fromArray(array(
                        'shortDescription' => 'When an instance created, it would be executed',
                        'longDescription'  => null,

                    ))
            );
            // ColumnMap()
            $generator->addMethod(
                'columnMap',
                array(),
                MethodGenerator::FLAG_PUBLIC,
                $columnMapBody,
                DocBlockGenerator::fromArray(array(
                    'shortDescription' => 'Column map for database fields and model properties',
                    'longDescription'  => null,
                ))
            );
            // initialize()
            if(!$generator->hasMethod("initialize")) {
                $generator->addMethod(
                    'initialize',
                    array(),
                    MethodGenerator::FLAG_PUBLIC,
                    'parent::initialize();' . "\n" .
                    '$this->setSource("'.$table.'");' . "\n" .
                    '$this->setWriteConnectionService("'. $dbService .'");' . "\n" .
                    '$this->setReadConnectionService("'.$dbService."Read".'");'
                );
            }
            // Write to file
            $file->write();
        }
        $this->cli->br()->info("将命名空间加入autoloader以发现Model相关的类: ");
        $this->cli->info("<red>".$model->getNamespace($useDbAsNamespace) . " -> ".$model->getDir($useDbAsNamespace)."/</red>");
        $this->cli->br()->info("... 恭喜您，创建成功！");
    }

    private function getDefaultValue($column)
    {
        if($column->hasDefault()) {
            switch($column->getType()) {
                case \Phalcon\Db\Column::TYPE_DATE:
                    return 'date("Y-m-d")';
                case \Phalcon\Db\Column::TYPE_TIMESTAMP:
                case \Phalcon\Db\Column::TYPE_DATETIME:
                    return 'date("Y-m-d H:i:s")';
                case \Phalcon\Db\Column::TYPE_TIME:
                    return 'date("H:i:s")';
                default:
                    return var_export($column->getDefault(), true);
            }
        } else {
            return var_export($this->getTypeDesc($column->getType())[1], true);
        }
    }

    private function getTypeDesc($type)
    {
        switch ($type) {
            case \Phalcon\Db\Column::TYPE_BIGINTEGER:
            case \Phalcon\Db\Column::TYPE_INTEGER:
            case \Phalcon\Db\Column::TYPE_TINYINTEGER:
            case \Phalcon\Db\Column::TYPE_SMALLINTEGER:
            case \Phalcon\Db\Column::TYPE_MEDIUMINTEGER:
                return ["integer", 0];
            case \Phalcon\Db\Column::TYPE_DATE:
                return ["date", "1000-01-01"];
            case \Phalcon\Db\Column::TYPE_TIMESTAMP:
                return ["timestamp", "1970-01-01 00:00:01"];
            case \Phalcon\Db\Column::TYPE_DATETIME:
                return ["datetime", "1000-01-01 00:00:00"];
            case \Phalcon\Db\Column::TYPE_TIME:
                return ["time", "00:00:00"];
            case \Phalcon\Db\Column::TYPE_CHAR:
            case \Phalcon\Db\Column::TYPE_TEXT:
            case \Phalcon\Db\Column::TYPE_TINYTEXT:
            case \Phalcon\Db\Column::TYPE_MEDIUMTEXT:
            case \Phalcon\Db\Column::TYPE_LONGTEXT:
            case \Phalcon\Db\Column::TYPE_VARCHAR:
                return ["string", ''];
            case \Phalcon\Db\Column::TYPE_FLOAT:
            case \Phalcon\Db\Column::TYPE_DOUBLE:
            case \Phalcon\Db\Column::TYPE_DECIMAL:
                return ["float", 0.00];
            case \Phalcon\Db\Column::TYPE_BOOLEAN:
                return ["bool", null];
            case \Phalcon\Db\Column::TYPE_TINYBLOB:
            case \Phalcon\Db\Column::TYPE_BLOB:
            case \Phalcon\Db\Column::TYPE_MEDIUMBLOB:
            case \Phalcon\Db\Column::TYPE_LONGBLOB:
                return ["blob", null];
            case \Phalcon\Db\Column::TYPE_JSON:
            case \Phalcon\Db\Column::TYPE_JSONB:
                return ["json", null];
            case \Phalcon\Db\Column::TYPE_BIT:
                return ["bit", null];
            case \Phalcon\Db\Column::TYPE_ENUM:
                return ["enum", null];
            default:
                return ["unknown", null];
        }
    }
}
