Feature: Statements
In order to experience the awesomeness of Treetop 
As a Rubyist
I want to witness the parsing of C-style statements
  
  Scenario Outline: Valid statements
    When I feed the parser a valid statement, <code>
    Then it should parse successfully
    
    Examples:
      | code                        |
      | ;                           |
      | 2 + 2;                      |
      | case face: lol;             |
      | case/*hai*/face: lol;       |
      | { 1 * 3; 4 + 7; }           |
      | {struct mystruct a = {0};}  |
      | if(i>u) i++;                |
      | do { i++; } while(i<5);     |
      | do(i++); while(i<5);        |
      | for(i=0;i<3;i++){}          |
      | for(int i=0;;){}            |
      | for ( ; ; ) { }             |
      | goto hell;                  |
      | return home;                |
      | return(pikachu);            |
    
    Scenario Outline: Invalid statements
      When I feed the parser an invalid statement, <code>
      Then it should fail to parse
    
    Examples:
      | cake face: lol;     |
      | if i < u {2 + 3;}   |
      | for(goto shop;;)    |

