---
layout: post
title: 'Test double php introduction'
date: 2014-11-20 21:32:00
categories: ['design pattern',testing']
---
When you start unit testing your code you don't want to test a full behavior of your code but just a little part in isolation to the rest. 
In order do do that you need to isolate your class from the other context, test doubles are tools (aka patterns) that allow you to do that.
There are five common test double:

1. Dummy
2. Stub
<!-- more -->
3. Spy
4. Mocks
5. Fake

A Dummy is an object that doest nothing (dummy) and it's passed to your object, you use dummy in order to pass mandatory field to your object but you don't really use them in your SUT (Suit under test). Here's an example of a dummy in php:

	Class DummyItem{}
	
	Class TestedClass{
		public function __construct($item){
			$this->item = $item;
		}
	}
	
Because your tested class depend on item you need to pass in an item but the class is not using the item in the reality of the test, the dummy is passed just do avoid runtime errors.

A Stub is something more intelligent than a simple Dummy, in fact it's used to force the execution of your code in a certain way, let's see an example:

	Class ExpensiveItemStub{
		public function getPrice(){
			return 1000000;
		}
	}
	
	class CustomerStub{
		public function getMoney(){
			return 100;
		}
	}
	
	Class TestedClass{
		public function canBuyItem($customer, array $items){
			$total_price = $this->calculateSum($items);
			
			if($total_price > $customer->getMoney() )
			{
				throw new Exception;
			}
		}
		
		public function calculateSum(array $items){
			$sum = 0;
			array_walk($items, function($item){
				$sum+=$item->getPrice();
			});
			return $sum;
		}
	}
	
	Class Test{
	
		/**
		* @expectedException Exception
		*/
		public function testCannotBuyOverpricedItems(){
			$tested = new TestedClass();
			
			$tested->canBuyItem( ( new CustomerStub), [(new ExpensiveItemStub)]);
		}
	}
	
What we do here is to create a CustomerStub and an ExpensiveItemStub in order to force the error Exception. So Stub help us to make the code follow a certain path.

Spies are something more clever than stub, in fact a spy can log some operation that is does and you can ask the class if something has occured, here's an example:

	class ItemSpy{
		protected $has_called = false;
	
		public funcion callMethod(){
			$this->has_called = true;
		}
		
		public function hasCalledMethod(){
			return $this->has_called;
		}
	}


Then in your test you can do something like that:

	$spy = new ItemSpy();
	
	$testClass = new TestClass($spy);
	
	// do some operation that calls callMethod on the spy
	
	// then assert:
	$this->assertTrue($spy->hasCalledMethod());
	
The smartest guy here is the Mock with a Mock object you can write expetations and then ask for them, there are many Mock library around for php, you can also create custom mock for your needs. Here's a simple example:

	class ItemMock{
	
		protected $has_called;
	
		public function callable(){
			$this->has_called = true;
		}
		
		public function checkExpetations()
		{
			if (! $this->has_called) throw new Exception("assertion explanation goes here");
		}
	
	}
	
	// then in your code
	
	// do something
	
	$mock->checkExcpetations();
	
When checking expetations if something goes wrong the mock will throw you an exception and write you a message that explains the problem, for this reason you generally put on your tearDown method the mockery::close() or some other method depending on the library you use that checks for your expetations. Common php mocking library are: [Mockery](https://github.com/padraic/mockery) or [phrophecy](https://github.com/phpspec/prophecy).

Finaly the Fake, a fake is an implementation that behave similiary as the real implementation but it's not suitable for production environment, the most common example is an in-memory Sqlite database to speed up tests.

Here we are, i've done the introduction to Test Double. Hope you enjoy! 




