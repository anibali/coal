Feature: C files

  In order to do some low-level programming
  As a Rubyist
  I want to be able to require C files
  
  Scenario: Blank
    Given a file named "blank.c" with:
      """
      
      """
    When I require "blank"
    Then nothing exciting should happen
  
  Scenario: Comments
    Given a file named "comments.c" with:
      """
      /* lol comment */
      // another comment
      
      """
    When I require "comments"
    Then nothing exciting should happen

  Scenario: Include
    Given a file named "include.c" with:
      """
      #include "stdio.h"
      
      """
    When I require "include"
    Then nothing exciting should happen
  
  Scenario: Function
    Given a file named "function.c" with:
      """
      void do_stuff()
      {
      }
      
      """
    When I require "function"
    Then the "do_stuff" Coal function should work
  
  Scenario: Functions
    Given a file named "functions.c" with:
      """
      void foo() {}
      void bar() {}
      
      """
    When I require "functions"
    Then the "foo" Coal function should work
    And the "bar" Coal function should work
  
  Scenario: "is_close" function
    Given a file named "is_close.c" with:
      """
      int is_close(float, float, float);
      
      int is_close(a, b, margin)
      {
        float diff = a > b ? a - b : b - a;
        return diff < margin;
      }
      
      """
    When I require "is_close"
    Then the "is_close" Coal function should work
  
  Scenario: Collatz function
    Given a file named "collatz.c" with:
      """
      /* 
       * Calculates the Collatz stopping time for a given number.
       * See http://en.wikipedia.org/wiki/Collatz_conjecture for more details.
       */
      unsigned long collatz(int n)
      {
        unsigned long count = 0;
        
        while(n > 1)
        {
          count += 1;
          
          if(n % 2 == 0)
            n /= 2;
          else
            n = n * 3 + 1;
        }
        
        return count;
      }
      
      """
    When I require "collatz"
    Then the "collatz" Coal function should work
    
    Scenario: Probability functions
    Given a file named "probability.c" with:
      """
      #include "math.h"

      /* 
       * Calculates the number of ways to choose 'r' things from a group of 'n'.
       * See http://algorithm.isgreat.org/doku.php?id=combinations for more details.
       */
      int choose(int n, int r)
      {
        /* Take advantage of symmetry to keep 'r' low */
        if(n - r < r) r = n - r;
        
        if(r == 0) return 1;
        
        int result = n;
        int i = 1;
        while(i < r)
        {
          result = (result / i) * (n - i);
          ++i;
        }
        
        return result / r;
      }

      /*
       * See http://algorithm.isgreat.org/doku.php?id=binomial_pdf for more details.
       */
      double binom_pdf(int n, double p, int r)
      {
        return choose(n, r) * pow(p, r) * pow(1 - p, n - r);
      }
      
      """
    When I require "probability"
    Then the "choose" Coal function should work
    And the "binom_pdf" Coal function should work
  
  Scenario: Function involving pointers
    Given a file named "pointer_demo.c" with:
      """
      int forty_two()
      {
        int x = 0;
        (*&x) = 42;
        return x;
      }
      
      """
    When I require "pointer_demo"
    Then the "forty_two" Coal function should work

