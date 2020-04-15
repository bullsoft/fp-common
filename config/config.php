<?php
// Visiable Variables
// $rootPath       -- dir of the project without trailing /

return [
    "application" => array(
        "debug" => false,
        "close" => false,
    ),
    'namespace' => array(
        "BullSoft"                 => $rootPath . '/common/vendor/BullSoft/',
        "App\\Com\\Protos"         => $rootPath . '/common/protos/',
        "PhalconPlus\\Com\\Protos" => $rootPath . '/common/protos/',
    ),
];


/* config.php ends here */
