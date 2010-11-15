Feature: Postfix expressions
In order to experience the awesomeness of Treetop 
As a Rubyist
I want to witness the parsing of C-style expressions
  
  Scenario Outline: Valid postfix expressions
    When I feed the parser a valid postfix_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code              |
      | 1++               |
      | foo++--           |
      | foo->bar          |
      | point.x           |
      | aphex[t](w)[i](n) |
    
    Scenario Outline: Invalid postfix expressions
      When I feed the parser an invalid postfix_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 1+++      |
      | a..b      |
      | pt.->y    |
  
  Scenario Outline: Valid unary expressions
    When I feed the parser a valid unary_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code      |
      | ++i       |
      | --42      |
      | ++--foo   |
      | -543      |
      | *ptr      |
      | *&value   |
      | ~bits     |
    
    Scenario Outline: Invalid unary expressions
      When I feed the parser an invalid unary_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
  
  Scenario Outline: Valid multiplicative expressions
    When I feed the parser a valid multiplicative_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | 1 * 4       |
      | 42 / 0      |
      | x % 2       |
      | 2*4%3       |
      | 1.0/2.0/3.0 |
    
    Scenario Outline: Invalid multiplicative expressions
      When I feed the parser an invalid multiplicative_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 1 /% 5    |
    
  Scenario Outline: Valid additive expressions
    When I feed the parser a valid additive_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | 43 + 1      |
      | x - 32      |
    
    Scenario Outline: Invalid additive expressions
      When I feed the parser an invalid additive_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | x +       |
    
  Scenario Outline: Valid shift expressions
    When I feed the parser a valid shift_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | 2 >> n      |
      | x << 5      |
    
    Scenario Outline: Invalid shift expressions
      When I feed the parser an invalid shift_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 1 <<      |
    
  Scenario Outline: Valid relational expressions
    When I feed the parser a valid relational_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | x <= 1      |
      | 3 >= 2.9    |
      | 1 < 2       |
      | 345 > z     |
    
    Scenario Outline: Invalid relational expressions
      When I feed the parser an invalid relational_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 1 <=      |
  
  Scenario Outline: Valid equality expressions
    When I feed the parser a valid equality_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | x == 2      |
      | 1 != 2      |
    
    Scenario Outline: Invalid equality expressions
      When I feed the parser an invalid equality_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 1 ==      |
      | != 5      |
    
  Scenario Outline: Valid and expressions
    When I feed the parser a valid and_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | x & 3       |
    
    Scenario Outline: Invalid and expressions
      When I feed the parser an invalid and_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 1 &       |
    
  Scenario Outline: Valid logical and expressions
    When I feed the parser a valid logical_and_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | x && 3      |
    
    Scenario Outline: Invalid logical and expressions
      When I feed the parser an invalid logical_and_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 1 &&      |
    
  Scenario Outline: Valid assignment expressions
    When I feed the parser a valid assignment_expression, <code>
    Then it should parse successfully
    
    Examples:
      | code        |
      | x = 3       |
      | x <<= 4     |
      | i *= 2      |
    
    Scenario Outline: Invalid assignment expressions
      When I feed the parser an invalid assignment_expression, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | 1 @= 3    |
      | x &&= 3   |
      | = 42      |

