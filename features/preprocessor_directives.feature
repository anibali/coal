Feature: Preprocessor directives
In order to experience the awesomeness of Treetop 
As a Rubyist
I want to witness the parsing of C-style preprocessor directives
  
  Scenario Outline: Valid header name
    When I feed the parser a valid header_name, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | <header>    |
      | <header<>   |
      | <"header">  |
      | "<header>"  |
    
  Scenario Outline: Invalid header name
    When I feed the parser an invalid header_name, <code>
    Then it should fail to parse
    
    Examples:
      | code        |
      | <header>>   |
      | "header""   |
      
