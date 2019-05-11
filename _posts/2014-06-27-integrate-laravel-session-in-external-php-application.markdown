---
layout: post
title: 'Integrate Laravel And Session in external php application'
date: 2014-06-27 12:24:00
categories: ['laravel']
---
Hello foks, it's been a while since i didn't write an article. Today i'll explain you how you can integrate Laravel framework 4 (and his session driver) in any other php application.
I'm writing this because i had to solve this problem in one of my works and i want to share this with you.
<!-- more -->
You may say, why i should do that? Well, for multiple reasons, the first one i can find is if you want to use your laravel app authentication in an external php file or application (in orded to do that you need to use the laravel app session driver).

To integrate Laravel4 in another php application you need to follow 2 main steps: 

1. Boot up laravel framework
2. Start the session driver manager that i've created

The first part is trivial, all you have to do is put the following code in a **.php** file and include it in your application:

	<?php
	// boot laravel
	require __DIR__ .'/../../vendor/autoload.php';
	$laravel_app = require __DIR__ .'/../../bootstrap/start.php';
	$laravel_app->boot();

You have to replace the require path with the correct one depending on where is located your laravel framework installation.
Then after the bootstrap of your application put the following code: 
	
	// boot session
	require __DIR__ .'/laravelManager.php';
	$manager = new laravelSessionManager($laravel_app);
	$manager->startSession();
	
This simple script will start laravel session with the help of the session manager class (LaravelManager.php) that i've created. The session manager class code is here:

	<?php
	/**
	 * Class laravelManager
	 *
	 * @author jacopo beschi jacopo@jacopobeschi.com
	 *
	 * remember to use Session::save() to persist the data
	 */
	use Illuminate\Session\SessionManager;
	use Illuminate\Encryption\Encrypter;

	class laravelSessionManager
	{
    public $laravel;

    protected $cookie_name;

    protected $app_key;

    public function __construct($laravel)
    {
        $this->laravel = $laravel;
        $this->app_key = $this->laravel['config']['app.key'];
        $cookie_name = $this->laravel['config']['session.cookie'];
        $this->cookie_name = isset($_COOKIE[$cookie_name]) ? $_COOKIE[$cookie_name] : false;
    }

    public function startSession()
    {
        $encrypter = $this->createEncrypter();

        $manager = new SessionManager($this->laravel);
        $session = $manager->driver();

        $this->updateSessionId($encrypter, $session);

        $session->start();

        $this->bindNewSession($session);
    }

    /**
     * @return Encrypter
     */
    private function createEncrypter()
    {
        $encrypter = new Encrypter($this->app_key);
        return $encrypter;
    }
    /**
     * @param $encrypter
     * @param $session
     */
    private function updateSessionId($encrypter, $session)
    {
        if($this->cookie_name)
        {
            $sessionId = $encrypter->decrypt($this->cookie_name);
            $session->setId($sessionId);
        }
    }

    /**
     * @param $session
     */
    private function bindNewSession($session)
    {
        App::instance('session', $session);
        App::instance('session.store', $session);
    }

	}
	
This class basically boot up laravel session driver using your laravel configuration settings in a transparent way.<br/>
After the **$manager->startSession();** code you can use the whole laravel framework (authenticatoin session and more) in your external php application, isn't that lovely? 

Have any questions? Feel free to ask me. 
Happy coding!

