<?php
namespace PhalconPlus\DevTools\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use PhalconPlus\Logger\MultipleFile as MulitFileLogger;
use PhalconPlus\Logger\Processor\Trace as TraceProcessor;
use PhalconPlus\Logger\Processor\LogId as LogIdProcessor;
use PhalconPlus\Logger\Processor\Msec as MsecProcessor;
use Phalcon\Logger\Formatter\Line as LineFormatter;


use Ph\{Config, };

class LoggerServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared("logger", function() {
            $logger = new MulitFileLogger(Config::get('logger')->toArray());
            $logger->addProcessor("logId", new LogIdProcessor(18));
            $logger->addProcessor("trace", new TraceProcessor(TraceProcessor::T_CLASS));
            $logger->addProcessor("msec", new MsecProcessor());
            // 添加formatter
            $formatter = new LineFormatter("[%date%.{msec}][{trace}][{logId}][%type%] %message%");            

            $formatter->setDateFormat("Y-m-d H:i:s");
            $logger->setFormatter($formatter);
            return $logger;
        });
    }
}