<?php
// Visiable Variables
// $rootPath       -- dir of the app
// $di             -- global di container
// $config         -- the Phalcon\Config object
// $superapp       -- superapp object
// $loader         -- Phalcon\Loader object
use Phalcon\Logger\Logger;

return [
    'application' => [
        "name"  => "fp-devtool",
        "ns"    => "PhalconPlus\\DevTools\\",
        "mode"  => "Cli",
    ],
    "logger" => [
        [
            "filePath" => "/tmp/fp-devtool.log.debug",
            "level" => Logger::DEBUG
        ],
        [
            "filePath" => "/tmp/fp-devtool.log",
            "level" => Logger::CUSTOM
        ]
    ],
    'version' => "3.0.2",
];

/* config.php ends here */
