$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)
);

if(in_array(pathinfo($uri, PATHINFO_EXTENSION), [
    "ico", "jpeg", "jpg", "png", "gif", "svg", "css", "js", 
    "woff", "woff2", "eot", "ttf", "json", "map", "scss",
])) {
    return false;
}

if ($uri !== '/' && is_file($_SERVER['DOCUMENT_ROOT'] . $uri)) {
    return false;
}

require $_SERVER['DOCUMENT_ROOT'] . '/index.php';