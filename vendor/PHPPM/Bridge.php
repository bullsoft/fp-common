<?php

namespace PHPPM\Bridges\PhalconPlus;

use PHPPM\Bootstraps\ApplicationEnvironmentAwareInterface;
use PHPPM\Bridges\BridgeInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Message\ResponseInterface;
use GuzzleHttp\Psr7;
use PhalconPlus\Http\PsrResponseFactory;

class Bridge implements BridgeInterface
{
    /**
     * @var \PhalconPlus\App\App
     */
    protected $app;

    /**
     * Bootstrap an PhalconPlus application.
     *
     * In the process of bootstrapping we decorate our application with any number of
     * *middlewares* using StackPHP's Stack\Builder.
     *
     * The app bootstraping itself is actually proxied off to an object implementing the
     * PHPPM\Bridges\BridgeInterface interface which should live within your app itself and
     * be able to be autoloaded.
     *
     * @param string $appBootstrap The name of the class used to bootstrap the application
     * @param string|null $appenv The environment your application will use to bootstrap (if any)
     * @param boolean $debug If debug is enabled
     */
    public function bootstrap($appBootstrap, $appenv, $debug)
    {
        $appBootstrap = $this->normalizeAppBootstrap($appBootstrap);

        $pmBootstrap = new $appBootstrap(getcwd(), $appenv);
        if ($pmBootstrap instanceof ApplicationEnvironmentAwareInterface) {
            $pmBootstrap->initialize($appenv, $debug);
        }
        
        $this->app = $pmBootstrap->app();
    }

    /**
     * {@inheritdoc}
     */
    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        if (null === $this->app) {
            // internal server error
            return new Psr7\Response(500, ['Content-type' => 'text/plain'], 'PhalconPlus\\Boostrap not configured during bootstrap');
        }
        $resp = $this->app->handle($request);
        $this->app->terminate();
        return PsrResponseFactory::create($resp);
    }


    /**
     * @param string $appBootstrap
     * @return string
     * @throws \RuntimeException
     */
    protected function normalizeAppBootstrap($appBootstrap)
    {
        $appBootstrap = str_replace('\\\\', '\\', $appBootstrap);
        $bootstraps = [
            $appBootstrap,
            '\\' . $appBootstrap,
            '\\PHPPM\Bootstraps\\' . ucfirst($appBootstrap)
        ];

        foreach ($bootstraps as $class) {
            if (class_exists($class)) {
                return $class;
            }
        }
    }
}
