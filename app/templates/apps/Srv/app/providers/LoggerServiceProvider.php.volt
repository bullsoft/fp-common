namespace {{rootNs}}\Providers;

use Phalcon\Di\DiInterface;
use Phalcon\Di\ServiceProviderInterface;
use PhalconPlus\Logger\MultipleFile as MulitFileLogger;
use PhalconPlus\Logger\Processor\Trace as TraceProcessor;
use PhalconPlus\Logger\Processor\LogId as LogIdProcessor;
use Phalcon\Logger\Formatter\Line as LineFormatter;


use Ph\{Config,};

class LoggerServiceProvider implements ServiceProviderInterface
{
    public function register(DiInterface $di) : void
    {
        $di->setShared("logger", function() {
            $logger = new MulitFileLogger(Config::get('logger')->toArray());
            // Add formatter
            $formatter = new LineFormatter("[%date%][{trace}][{logId}][%type%] %message%");
            $formatter->setDateFormat("Y-m-d H:i:s");

            $logger->addProcessor("logId", new LogIdProcessor(18))
                   ->addProcessor("trace", new TraceProcessor(TraceProcessor::T_CLASS))
                   ->setFormatter($formatter);

            return $logger;
        });
    }
}