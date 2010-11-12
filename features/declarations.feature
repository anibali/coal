Feature: Declarations
In order to experience the awesomeness of Treetop 
As a Rubyist
I want to witness the parsing of C-style declarations
  
  Scenario Outline: Valid declarations
    When I feed the parser a valid declaration, <code>
    Then it should parse successfully
    
    Examples:
      | code                              |
      | int x;                            |
      | int arr[5];                       |
      | extern int *x;                    |
      | extern int y[];                   |
      | float fa[11], *afp[17];           |
      | int a[n][6][m];                   |
      | int (*p)[4][n+1];                 |
      | enum foo;                         |
      | enum colours {red, green, blue};  |
      | enum distros {ubuntu, fedora,};   |
      | struct mystruct a = {0};          |
    
    Scenario Outline: Invalid declarations
      When I feed the parser an invalid declaration, <code>
      Then it should fail to parse
    
    Examples:
      | code      |
      | int x 5;  |
      | intfoo;   |

