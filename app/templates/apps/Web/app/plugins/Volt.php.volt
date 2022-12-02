namespace {{rootNs}}\Plugins;
use Phalcon\Di\Injectable as DiInjectable;
use Plus\{Security, };

class Volt extends DiInjectable
{
    public static function csrfToken()
    {
        return '<input type="hidden" name="' . 
            Security::getTokenKey().'" value="' .
            Security::getToken().'" />';
    }
}
