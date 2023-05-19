lexer grammar SysyLex;

// keyword
INT : 'int';
FLOAT : 'float';
VOID : 'void';
CONST : 'const';
RETURN : 'return';
IF : 'if';
ELSE : 'else';
WHILE : 'while';
BREAK : 'break';
CONTINUE : 'continue'; 

// delimeter
LP : '(' ;
RP : ')' ;
LB : '[' ;
RB : ']' ;
LC : '{' ;
RC : '}' ;
COMMA : ',' ;
SEMICOLON : ';';
QUESTION : '?';
COLON : ':';

// operator
MINUS : '-';
NOT : '!';
ASSIGN : '=';
ADD : '+';
MUL : '*';
DIV : '/';
MOD : '%';
AND : '&&';
OR : '||';
EQ : '==';
NEQ : '!=';
LT : '<';
LE : '<=';
GT : '>';
GE : '>=';



INT_LIT : [1-9][0-9]*
    | '0'[0-7]*
    | '0'[xX]([0-9]|[a-fA-F])*
    ;

FLOAT_LIT : [+-]?(('.'[0-9]+([eE][+-]?[0-9]+)?[fF]?)|([0-9]+'.'[0-9]*([eE][+-]?[0-9]+)?[fF]?)|([0-9]+[eE][+-]?[0-9]+[fF]?));



ID : [A-Za-z_][A-Za-z0-9_]*;
// float literal


// fragment for float literal


// identifier

// string
STRING : '"'(ESC|.)*?'"';

// for string
fragment
ESC : '\\"'|'\\\\';

// whitespace
WS : 
    [ \t\r\n] -> skip
    ;

// comments
LINE_COMMENT : '//' .*? '\r'? '\n' -> skip;
BLOCK_COMMENT : '/*'.*?'*/'-> skip ;


LEX_ERR : '0'[0-9]* | [0-9a-zA-Z]* ;