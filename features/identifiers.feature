Feature: Identifiers
In order to experience the awesomeness of Treetop 
As a Rubyist
I want to witness the parsing of C-style identifiers
  
  Scenario Outline: Valid identifiers
    When I feed the parser a valid identifier, <code>
    Then it should parse successfully
    
    Examples:
      | code      |
      | x         |
      | foo       |
      | n_turns   |
      | _         |
      | _foo      |
      | barBaz    |
      | BOO       |
      | _1        |
      | tmp2      |
    
    Scenario Outline: Invalid identifiers
      When I feed the parser an invalid identifier, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 2ndvar    |
      | $foo      |

