// Visiable Variables
// $rootPath       -- string, dir of the app without trailing /
// $di             -- the <Phalcon\Di> object, global di container
// $config         -- the <Phalcon\Config> object
// $loader         -- the <Phalcon\Loader> object
// $superapp       -- the <PhalconPlus\App\App> object
// $def            -- the <PhalconPlus\App\Module\ModuleDef> object

return [
    'application' => [
        "name"  => "{{module}}",
        "ns"    => "{{rootNs}}\\",
        "mode"  => "Srv",
        "url" => "http://127.0.0.1:{{port}}", // Without trailing "/"
        "key" => "{{secKey}}",
        "roles" => [
            "Guests"  => [],
            "Members" => ["Guests"],
            "Admin"   => ["Guests", "Members"],
            "Super"   => ["Guests", "Members", "Admin"],
        ],
    ],
    "view" => [
        "dir" => $def->getDir() . "/app/views/",
        "compiledPath"      => $def->getDir()."/var/cache/view-compiled/",
        "compiledExtension" => ".compiled",
    ],
    "logger" => [
        [
            "filePath" => $def->getDir()."/var/log/debug.log",
            "level" => \Phalcon\Logger::DEBUG
        ],
        [
            "filePath" => $def->getDir()."/var/log/all.log",
            "level" => \Phalcon\Logger::CUSTOM
        ]
    ],
    'db' => [
        "host" => "127.0.0.1",        
        "port" => 3306,
        "username" => "root",
        "password" => "",
        "dbname" => "uc",
        "charset" => "utf8",
        "persistent" => false,
        "timeout" => 3, // 3 秒
        "retryInterval" => 200000, // 失败重试间隔200ms
        "retryTimes" => 5, //失败重试次数
        "options" => [
            \PDO::ATTR_EMULATE_PREPARES => false,
            // \PDO::ATTR_PERSISTENT => true,
        ],
    ],
    "redis" => [
        'host' => "127.0.0.1",
        "port" => 6379
    ],
];

/* config.php ends here */