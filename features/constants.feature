Feature: Constants

  In order to experience the awesomeness of Treetop 
  As a Rubyist
  I want to witness the parsing of C-style constants
  
  Scenario Outline: Valid integer constants
    When I feed the parser a valid integer_constant, <code>
    Then it should parse successfully
    And the produced tree node should have attributes {value: <value>}
    
    Examples:
      | code      | value     |
      | 5         | 5         |
      | 234       | 234       |
      | 342u      | 342       |
      | 128UL     | 128       |
      | 123456789 | 123456789 |
      | 5432l     | 5432      |
      | 763564lu  | 763564    |
      | 2344325ll | 2344325   |
      | 5424lLu   | 5424      |
      | 0xffffff  | 16777215  |
      | 0x123abc  | 1194684   |
      | 0x0       | 0         |
      | 0xadeu    | 2782      |
      | 0x98aL    | 2442      |
      | 01        | 1         |
      | 01237     | 671       |
      | 0634ul    | 412       |
    
    Scenario Outline: Invalid integer constants
      When I feed the parser an invalid integer_constant, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 57_23     |
      | 1xff      |
      | 01938     |
    
    Scenario Outline: Valid floating point constants
    When I feed the parser a valid floating_constant, <code>
    Then it should parse successfully
    And the produced tree node should have attributes {value: <value>}
    
    Examples:
      | code      | value   |
      | 4.2       | 4.2     |
      | 0.123     | 0.123   |
      | .5        | 0.5     |
      | 7.        | 7.0     |
      | 10.9F     | 10.9    |
      | 2.f       | 2.0     |
      | .9l       | 0.9     |
      | 2e-2      | 0.02    |
      | 4.2e3     | 4200.0  |
      | 0x2a.5p3  | 338.5   |
      | 0xafp-2   | 43.75   |
    
    Scenario Outline: Invalid floating point constants
      When I feed the parser an invalid floating_constant, <code>
      Then it should fail to parse
      
    Examples:
      | code      |
      | 0.54fl    |
      
    Scenario Outline: Valid escape sequences
      When I feed the parser a valid escape_sequence, <code>
      Then it should parse successfully
    
    Examples:
      | code      | value |
      | \\\n      | 10    |
      | \\\x4f    | 79    |
      | \\\1      | 1     |
      | \\\22     | 18    |
      | \\\123    | 83    |
    
    Scenario Outline: Invalid escape sequences
      When I feed the parser an invalid escape_sequence, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | \\\l      |
      | \\\xx     |
      | \\\8      |
      | \\\1234   |
    
    Scenario Outline: Valid character constants
      When I feed the parser a valid character_constant, <code>
      Then it should parse successfully
      And the produced tree node should have attributes {value: <value>}
    
    Examples:
      | code      | value   |
      | ' '       | 32      |
      | 'a'       | ?a      |
      | '#'       | ?#      |
      | '\\\''    | ?'      |
      | 'abc'     | ?a      |
    
    Scenario Outline: Invalid character constants
      When I feed the parser an invalid character_constant, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | ''        |
      | '''       |
      | '\\\'     |
      
    Scenario Outline: Valid strings
      When I feed the parser a valid string_literal, <code>
      Then it should parse successfully
      And the produced tree node should have attributes {value: <value>}
    
    Examples:
      | code      | value   |
      | ""        | ""      |
      | "hello"   | "hello" |
      | "\\\""    | "\\\""  |
  
    Scenario Outline: Invalid strings
      When I feed the parser an invalid string_literal, <code>
      Then it should fail to parse
  
    Examples:
      | code      |
      | """       |
      | "\\\"     |

