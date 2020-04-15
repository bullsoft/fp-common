<?php
// Visiable Variables
// $rootPath       -- dir of the app
// $di             -- global di container
// $config         -- the Phalcon\Config object
// $superapp       -- superapp object
// $loader         -- Phalcon\Loader object

return [
    'application' => [
        "name"  => "fp-devtool",
        "ns"    => "PhalconPlus\\DevTools\\",
        "mode"  => "Cli",
    ],
    "logger" => [
        [
            "filePath" => "/tmp/fp-devtool.log.debug",
            "level" => \Phalcon\Logger::DEBUG
        ],
        [
            "filePath" => "/tmp/fp-devtool.log",
            "level" => \Phalcon\Logger::SPECIAL
        ]
    ],
    'version' => "1.2.0",
];

/* config.php ends here */
