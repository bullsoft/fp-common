namespace {{rootNs}}\Plugins;
use Ph\{Security, };

class Volt extends \Phalcon\Di\Injectable
{
    public static function csrfToken()
    {
        return '<input type="hidden" name="' . 
            Security::getTokenKey().'" value="' .
            Security::getToken().'" />';
    }
}
