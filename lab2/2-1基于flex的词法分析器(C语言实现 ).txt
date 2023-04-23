%option noyywrap
%option yylineno

%{
#include <stdio.h>

enum Token {
    INT=258, FLOAT, VOID, CONST, RETURN, IF, ELSE,  WHILE, BREAK, CONTINUE,
    LP, RP, LB, RB, LC, RC, COMMA, SEMICOLON, QUESTION, COLON,
    MINUS, NOT, TILDE, ASSIGN, ADD, MUL, DIV, MOD, AND, OR,
    EQ, NE, LT, LE, GT, GE,
    ID, INT_LIT, FLOAT_LIT,
    LEX_ERR
};

// int lerror(int yylineno, char *yytext) {
//     printf("Lexical error - line %d : %s\n",yylineno,yytext);
//     return LEX_ERR;
// }
// #define LERROR() lerror(yylineno, yytext)
%}

DIGIT [0-9]
LETTER [A-Za-z]
IDEN [A-Za-z_][A-Za-z0-9_]*

DEC_INTEGER ([0-9]+)
HEX_INTEGER 0[xX]({DIGIT}|[A-Fa-f])+
OCTAL_INTEGER 0([0-7])+
INTEGER [+-]?{DEC_INTEGER}|{HEX_INTEGER}|{OCTAL_INTEGER}

FLOAT [+-]?(([.][0-9]+([eE][+-]?[0-9]+)?[fF]?)|([0-9]+[.][0-9]*([eE][+-]?[0-9]+)?[fF]?)|([0-9]+[eE][+-]?[0-9]+[fF]?))


MultilineComment "/*"([^\*]|(\*)*[^\*/])*(\*)*"*/"
SingleLineComment "//".*$


%%

"int" {printf("%s : INT\n", yytext); return INT; }
"float" {printf("%s : FLOAT\n", yytext); return FLOAT; }
"void" {printf("%s : VOID\n", yytext); return VOID; }
"const" {printf("%s : CONST\n", yytext); return CONST; }
"return" {printf("%s : RETURN\n", yytext); ; return RETURN; }
"if" {printf("%s : IF\n", yytext); return IF; }
"else" {printf("%s : ELSE\n", yytext); return ELSE; }
"while" {printf("%s : WHILE\n", yytext); return WHILE; }
"break" {printf("%s : BREAK\n", yytext); return BREAK; }
"continue" {printf("%s : CONTINUE\n", yytext); return CONTINUE; }

"(" {printf("%s : LP\n", yytext); return LP; }
")" {printf("%s : RP\n", yytext); return RP; }
"[" {printf("%s : LB\n", yytext); return LB; }
"]" {printf("%s : RB\n", yytext); return RB; }
"{" {printf("%s : LC\n", yytext); return LC; }
"}" {printf("%s : RC\n", yytext); return RC; }
"," {printf("%s : COMMA\n", yytext); return COMMA; }
";" {printf("%s : SEMICOLON\n", yytext); return SEMICOLON; }
"?" {printf("%s : QUESTION\n", yytext); return QUESTION; }
":" {printf("%s : COLON\n", yytext); return COLON; }
"!" {printf("%s : NOT\n", yytext); return NOT; }
"=" {printf("%s : ASSIGN\n", yytext); return ASSIGN; }
"-" {printf("%s : MINUS\n", yytext); return MINUS; }
"+" {printf("%s : ADD\n", yytext); return ADD; }
"*" {printf("%s : MUL\n", yytext); return MUL; }
"/" {printf("%s : DIV\n", yytext); return DIV; }
"%" {printf("%s : MOD\n", yytext); return MOD; }
"&&" {printf("%s : AND\n", yytext); return AND; }
"||" {printf("%s : OR\n", yytext); return OR; }
"==" {printf("%s : EQ\n", yytext); return EQ; }
"!=" {printf("%s : NE\n", yytext); return NE; }
"<" {printf("%s : LT\n", yytext); return LT; }
"<=" {printf("%s : LE\n", yytext); return LE; }
">" {printf("%s : GT\n", yytext); return GT; }
">=" {printf("%s : GE\n", yytext); return GE; }

{FLOAT} {printf("%s : FLOAT_LIT\n", yytext); return FLOAT_LIT; }
{IDEN} {printf("%s : ID\n", yytext); return ID; }
{INTEGER} {
    if ('0' == yytext[0] && 'x' != yytext[1] && 'X' != yytext[1]) {
        for(char *c = yytext; *c != '\0'; c++) {
            if (*c < '0' || *c > '7') {
                printf("Lexical error - line %d : %s\n",yylineno,yytext);
                return LEX_ERR;
            }
        }
    }
    printf("%s : INT_LIT\n", yytext); 
    return INT_LIT; 
}

{MultilineComment} {}
{SingleLineComment} {}


[ \n] {}
[ \r\t] {}
[ \n\t]+ {}
. {printf("Lexical error - line %d : %s\n",yylineno,yytext);return LEX_ERR;}
{INTEGER}{IDEN} {printf("Lexical error - line %d : %s\n",yylineno,yytext);return LEX_ERR;}


%%


int main(int argc, char** argv) {
    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
           perror(argv[1]); 
           return  1; 
        }       

       int symbol; 
       while( symbol = yylex()) { };

       fclose(yyin);
    } else printf("No source file given!\n"); 

    return 0; 
    
}

