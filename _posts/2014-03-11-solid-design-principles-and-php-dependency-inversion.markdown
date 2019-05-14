---
layout: post
title: 'SOLID Design principles and Php: Dependency inversion'
date: 2014-03-11 12:40:00
categories: ['design pattern','laravel','solid']
---
This is the last article about the SOLID principles series. In this article we talk about the D in SOLID: "**Dependency inversion**".  This last part may be the harder to understand for you guys. Before saying the principle we need to explain some definitions:
- **High level code**:  the code that is focused on solving a general problem (For example db access)
- **Low level code**:  the code focused on solving a particular problem. 
<!-- more -->
Keep this definition as it is for now, the Dependency inversion principle says: Every implementation of high level code should not depend on the implementation of low level code, instead should depend on an interface. Again as you see all the principles gets into the "Program the interface" principle. This principle is based on reducing coupling between the code, allowing easier testing and mantainance of the code itself. Now let's dig in with an example: 
Imagine we are handling a subscription form and at one point we need to send an email to the client. 

	use Mail;
  	Class UserSubscriptionService
  	{
		public function subscribe($user)
		{
			// do something...
			// send email to the user mail
			$this->sendMail($user->email);
		}
		
		protected function sendMail($email)
		{
			Mail::queue($template, ["body" => $body], function($message) use($to, $subject){
					$message->to($email)->subject($subject);
				});
		}
  	}
As you can see we use Mail to send email, the problem here is that we violate the dependency inversion principle, in fact the High level code(**UserSubscriptionService**) depends on the low level code (**Mail**). What we need to do here to solve the problem is to create an interface and let the Class use that interface instead of the class itself. Let's create the interface:

	interface MailerInterface
	{
	  /**
	   * Interface to send emails
	   *
	   * @param $to
	   * @param $body
	   * @param $subject
	   * @param $template
	   * @return boolean $success
	   */
	  public function sendTo($to, $body, $subject, $template);
	}
	
Allright, now we create the mailer implementation of that:
	  
	  class SwiftMailer implements MailerInterface {
		/**
		 * {@inheritdoc}
		 */
		public function sendTo($to, $body, $subject, $template)
		{
			try
			{
				Mail::queue($template, ["body" => $body], function($message) use($to, $subject){
					$message->to($to)->subject($subject);
				});
			}
			catch( \Swift_TransportException $e)
			{
				Log::error('Cannot send the email: '.$e->getMessage());
				return false;
			}
			catch( \Swift_RfcComplianceException $e)
			{
				Log::error('Cannot send the email: '.$e->getMessage());
				return false;
			}
	
			return true;
		}
	  }
	
Perfect, now the last part is to user make the dependency of the interface instead on the service class:
	
	Class UserSubscriptionService
  	{
		//.....
		
		protected function sendMail($email, MailerInterface $mailer)
		{
			$mailer->sendTo($obj->email, [ "body" => "body" ], "Subject...");	
		}
  	}
	
Perfect, now we need to pass either the SwitfMailer implementation to sendMail or we can also use laravel IOC container and instead put this code in app/start/global.php (or if you prefer put it in a ServiceProvider):

	App::bind('MailerInterface', function(){return new SwiftMailer()});
	
By doing that we bind the interface to the implementation, why do that? Well, imagine that we send email form many part of our application and at one point we want to use a different library; by doing that you dont have to change every line of code where you send emails but instead you can just swap one line of code. Isn't it brilliant? Any comments? Fill the form below. We are done for today.
Thanks for reading folks!