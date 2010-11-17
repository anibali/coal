Feature: C files

  In order to do some low-level programming
  As a Rubyist
  I want to be able to require C files
  
  Scenario: Blank
    Given a file named "blank.c" with:
      """
      
      """
    When I require "blank"
    Then no exception should be raised
  
  Scenario: Comments
    Given a file named "comments.c" with:
      """
      /* lol comment */
      // another comment
      
      """
    When I require "comments"
    Then no exception should be raised

  Scenario: Include
    Given a file named "include.c" with:
      """
      #include "stdio.h"
      
      """
    When I require "include"
    Then no exception should be raised
  
  Scenario: Function
    Given a file named "function.c" with:
      """
      void do_stuff()
      {
      }
      
      """
    When I require "function"
    Then no exception should be raised
    And the Coal namespace should respond to "do_stuff"

