namespace {{rootNs}}\Services;
use PhalconPlus\Base\SimpleRequest as SimpleRequest;

class DemoService extends BaseService
{
    public function main(SimpleRequest $request)
    {
    	return $request->toArray() + ["successful" => true];
    }
}