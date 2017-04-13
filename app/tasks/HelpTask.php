<?php

namespace PhalconPlus\DevTools\Tasks;

class HelpTask extends \Phalcon\CLI\Task
{
    private $c;

    public function initialize()
    {
        $this->c = 1;
    }

    public function mainAction()
    {
        $climate = new \League\CLImate\CLImate();
        $climate->draw('bender');
        $climate->br()->blue('可用<light_red>命令</light_red>如下: ');

        $data = [
            [
                'Create',
                'Father',
                'Teacher',
            ],
            [
                'Skyler White',
                'Mother',
                'Accountant',
            ],
            [
                'Walter White Jr.',
                'Son',
                'Student',
            ],
        ];

        foreach($data as $item) {
            $climate->padding(20)->label("   " . $item[0])->result($item[1]);
        }

    }
}