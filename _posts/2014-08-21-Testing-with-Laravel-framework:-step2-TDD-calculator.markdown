---
layout: post
title: 'Testing in Laravel framework: step2 TDD calculator'
date: 2014-08-21 10:29:00
categories: ['testing']
---
Hello again, in the previous article i've explained how to run your first test. 
Now we go a little more in detail and we tackle a real example.What we are going to do is write the calculator in TDD (test first). We incrementally build the calculator step after step. 
The step will be the following:

1. Create a simple String calculator with a method int Add(string numbers)
2. The method can take 0, 1 or 2 numbers, and will return their sum (for an empty string it will return 0) for example “” or “1” or “1,2”
3. Allow the Add method to handle an unknown amount of numbers
<!-- more -->
4. Allow the Add method to handle new lines between numbers (instead of commas).
5. the following input is ok:  “1\n2,3”  (will equal 6) the following input is NOT ok:  “1,\n” (not need to prove it - just clarifying)
6. Support different delimiters: to change a delimiter, the beginning of the string will contain a separate line that looks like this:   “//[delimiter]\n[numbers…]” for example “//;\n1;2” should return three where the default delimiter is ‘;’ .the first line is optional. all existing scenarios should still be supported
 
Ok the first step is to have a fully working environment: we already have installed phpunit and php so we should start from the first test: constructor.

	<?php 

	  class CalculatorTest extends PHPUnit_Framework_TestCase{
  
	  /**
	   * @test
	   */
	  public function canInitalizeCalculator()
	  {
		  new Calculator();
	  }
	}

	class Calculator{
		
	}

Now we know we have a fully working enviroment, lets get started with the step1. 
We start always from the simple stuff, so let's calculate the sum of "0". keep in mind that I'm always making the test fail before writing the production code, but here i'm showing you the test code with the production code at the same time:

	<?php
	......
	
	 /**
	   * @test
	   **/
	  public function canCalculateSum()
	  {
		$this->assertAdd(0,"0");
	  }
	
	  protected function assertAdd($result, $input)
	  {
		$this->assertEquals($result, $this->calculator->add($input));
	  }
	
	}
	
	class Calculator{
	
		public function add($string)
		{
		return 0;
		}
	}

Allright, the test passes!  As you see i've made a method assertCalculate that basically check if the result of calculation will be equals.
So now our calculator can calculate the sum of 0, pretty simple for now but it works. 
Let's add some more compexity and our next step will be to calculate the sum of a number:

	/**
	   * @test
	   **/
	  public function canCalculateSum()
	  {
		$this->assertAdd(0,"0");
		$this->assertAdd(2,"2");
	  }

	class Calculator{

	  public function add($string)
	  {
	  return $string;
	  }
	}

Ok good now let's try to add two numbers:


	....
	/**
	   * @test
	   **/
	  public function canCalculateSum() {
		$this->assertAdd(0, "0");
		$this->assertAdd(2, "2");
		$this->assertAdd(4, "2,2");
	  }
	  ....
	     public function add($string) {
        $numbers = [];
        $j = 0;
        for($i = 0; $i < strlen($string); $i++) {
            if($string[$i] == ",") {
                $j++;
            }
            else
            {
                $numbers[$j]=$string[$i];
            }
        }

        return array_sum($numbers);
    }

What the code does is to loop thrugh the string and get the various numbers, then return their sum. 
This code works fine but when we try to sum a number with more then one digits the test will fail:

	public function canCalculateSum() {
			$this->assertAdd(0, "0");
			$this->assertAdd(2, "2");
			$this->assertAdd(4, "2,2");
			$this->assertAdd(24, "22,2");
		}
		
So now let's make it work with numbers with multiple digits:

	public function add($string) {
			$numbers = [];
			$j = 0;
			for($i = 0; $i < strlen($string); $i++) {
				if($string[$i] == ",") {
					$j++;
				}
				else
				{
					$numbers[$j] = isset($numbers[$j]) ? $numbers[$j] . $string[$i] : $string[$i];
				}
			}
	
			return array_sum($numbers);
		}

Perfect, now we want to do the step 4. In order to do that we realize that this code is a little messy, in fact we can have a better solution with just a regular expression:

	public function canCalculateSum() {
        $this->assertAdd(0, "0");
        $this->assertAdd(2, "2");
        $this->assertAdd(4, "2,2");
        $this->assertAdd(24, "22,2");
        $this->assertAdd(30, "22\n2\n6");
    }
	
    public function add($string) {
        preg_match_all('/(\d*)[\\n|,]?/', $string, $numbers);

        return array_sum($numbers[1]);
    }

And here we are, now the code pick up the numbers separated by comma or new line and returns their sum. 
Let's check for point 5 now. In order to do that we add this assert:

	/**
     * @test
     **/
    public function validatesInput()
    {
        $this->assertAdd(22, "22\n,2\n6");
    }

And this test fails, so now let's fix the code in order to make him stop when finds a wrong separator.

	public function add($string) {
	
	  if(preg_match('/[,|\\n][,|\\n]{1}/', $string)) {
		  throw new BadMethodCallException;
	  }
	  
	  preg_match_all('/(\d*)(?=[\\n|,])?/', $string, $numbers);
	
		return array_sum($numbers[1]);
	}

Allright it works now, but this isn't much readable isn't it? Let's do some refactoring!

	public function add($string) {

        $this->validateInput($string);

        $numbers = $this->extractNumbers($string);

        return array_sum($numbers);
    }

    /**
     * @param $string
     * @throws BadMethodCallException
     */
    protected function validateInput($string) {
        if(! $this->hasValidDelimiters($string)) {
            throw new BadMethodCallException;
        }
    }

    /**
     * @param $string
     * @return int
     */
    protected function hasValidDelimiters($string) {
        return ! preg_match('/[,|\\n][,|\\n]{1}/', $string);
    }

    /**
     * @param $string
     * @return mixed
     */
    protected function extractNumbers($string) {
        preg_match_all('/(\d*)(?=[\\n|,])?/', $string, $numbers);

        return $numbers[1];
    }
	
Here we go! Now we splitted up the code into many small readable methods: extract till you drop baby.
Time for step 6 now, so let's write this test:

	/**
     * @test
     **/
    public function canSupportGivenDelimiter()
    {
        $this->assertAdd(25,"//;\n20;5");
    }

We think that it's gonna fail but in fact... it passes! Lovely, so we have already solved that problem. The only problem is that certain input passes the sum while should throw and exception, let's write a test to fix that:

	/**
     * @test
     * @expectedException \BadMethodCallException
     **/
    public function validateCustomDelimiters()
    {
        $this->calculator->add("//;\n22;,2,;;6");
    }
	
The test fail, so we need to fix our input validation.

	 /**
     * @param $string
     * @throws BadMethodCallException
     */
    protected function validateInput($string) {

        if($string[0] == '/' && $string[1] == '/')
        {
            $this->delimiters = [$string[2]];
        }
        else
        {
            $this->delimiters = $this->default_delimiters;
        }

        if(! $this->hasValidDelimiters($string)) {
            throw new BadMethodCallException;
        }
    }

    /**
     * @param $string
     * @return int
     */
    protected function hasValidDelimiters($string) {

        $delimiters = '';
        foreach($this->delimiters as $key => $delimiter) {
            $delimiters.= $delimiter;
            if($key != (count($delimiters)-1) )
            {
                $delimiters.="|";
            }
        }

        return ! preg_match('/['.$delimiters.']['.$delimiters.']{1}/', $string);
    }

Right, the test passes now. But now it's time to do some refactoring!


    /**
     * @param $string
     * @throws BadMethodCallException
     */
    protected function validateInput($string) {

        $this->parseDelimiters($string);

        if(!$this->hasValidDelimiters($string)) {
            throw new BadMethodCallException;
        }
    }

    /**
     * @param $string
     */
    protected function parseDelimiters($string) {
        if($string[0] == '/'&&$string[1] == '/') {
            $this->delimiters = [$string[2]];
        }

        $this->delimiters = $this->default_delimiters;
    }

    /**
     * @param $string
     * @return int
     */
    protected function hasValidDelimiters($string) {

       return !preg_match(
                '/[' . $this->createDelimitersString() . ']' .
                '[' . $this->createDelimitersString() . ']' .
                '{1}/', $string
        );
    }

    /**
     * @return string
     */
    protected function createDelimitersString() {
        $delimiters = '';
        foreach($this->delimiters as $key => $delimiter) {
            $delimiters .= $delimiter;
            if($key != (count($delimiters) - 1)) {
                $delimiters .= "|";
            }
        }
        return $delimiters;
    }
	
Allright, now we have extracted the main logic again into small expressive methods. 
That's all for now, we're done. But that's a lot more to talk about, so stay tuned for the step3!




