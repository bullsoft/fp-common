<?php
// Visiable Variables
// $rootPath       -- dir of the app
// $config         -- global config object
// $superapp       -- the super app instant for PhalconPlus\App\App

mb_internal_encoding("UTF-8");

$app = $superapp;

// register global class-dirs, class-namespace and class-prefix
$globalNs = $config->namespace->toArray();
$loader->setNamespaces($globalNs, true)
       ->register();


// global funciton to retrive $di
if (!function_exists("getDI")) {
    function getDI()
    {
        global $app;
        return $app->di();
    }
}

if (!function_exists("di")) {
    function di()
    {
        global $app;
        return $app->di();
    }
}

if (!function_exists("supername")) {
    function supername(string $ns, int $levels)
    {
        $dir = strtr($ns, "\\", "/");
        $here = dirname($dir, $levels);
        return strtr($here, "/", "\\");
    }
}

/* default.php ends here */
