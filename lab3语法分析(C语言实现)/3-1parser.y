%define parse.error verbose
%locations
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "ast.h"

ASTNode *root;

extern FILE *yyin;
extern int line_cnt;
extern int yylineno;
extern char *yytext;
extern int yylex();
extern int yyparse();
//extern void yyerror(char *msg);
void yyerror(const char* fmt, ...);
int syntax_error = 0;
char filename[100];
%}

%union {
    int int_val;
    float float_val;
    char *str_val;
    struct ASTNode *node_val;
}

%type <node_val> CompUnit ConstDecl VarDecl FuncDef ConstDef ConstInitVal VarDef InitVal FuncFParam ConstExpArray Block
%type <node_val> Root BlockItem Stmt LVal PrimaryExp UnaryExp FuncRParams MulExp Exp RelExp EqExp LAndExp Cond ConstExp
%type <node_val> ExpArray AddExp LOrExp InitVals 
//ForList

%token <str_val> ID
%token <int_val> INT_LIT
%token <float_val> FLOAT_LIT

%token <int_val> INT FLOAT VOID CONST RETURN IF ELSE WHILE BREAK CONTINUE LP RP LB RB LC RC COMMA SEMICOLON
%token <int_val> MINUS NOT ASSIGN PLUS MUL DIV MOD AND OR EQ NE LT LE GT GE LEX_ERR 
//FOR INC DEC THEN

%nonassoc THEN
%nonassoc ELSE

%start Root

%%
Root: CompUnit { root = new_node(Root, NULL, NULL, $1, 0, 0,  NULL, NonType); };
CompUnit: ConstDecl { $$ = new_node(CompUnit, NULL, NULL, $1, 0, 0, NULL, NonType); }
        | VarDecl { $$ = new_node(CompUnit, NULL, NULL, $1, 0, 0, NULL, NonType); }
        | FuncDef { $$ = new_node(CompUnit, NULL, NULL, $1, 0, 0, NULL, NonType); }
        | ConstDecl CompUnit { $$ = new_node(CompUnit, $2, NULL, $1, 0, 0, NULL, NonType); }
        | VarDecl CompUnit { $$ = new_node(CompUnit, $2, NULL, $1, 0, 0, NULL, NonType); }
        | FuncDef CompUnit { $$ = new_node(CompUnit, $2, NULL, $1, 0, 0, NULL, NonType); };

ConstDecl: CONST INT ConstDef SEMICOLON { $$ = new_node(ConstDecl, NULL, NULL, $3, 0, 0, NULL, Int); }
         | CONST FLOAT ConstDef SEMICOLON { $$ = new_node(ConstDecl, NULL, NULL, $3, 0, 0, NULL, Float); };
ConstDef: ID ConstExpArray ASSIGN ConstInitVal { $$ = new_node(ConstDef, NULL, $2, $4, 0, 0, $1, NonType); }
        | ID ConstExpArray ASSIGN ConstInitVal COMMA ConstDef { $$ = new_node(ConstDef, $6, $2, $4, 0, 0, $1, NonType); };
ConstExpArray: { $$ = NULL; }
             | LB ConstExp RB ConstExpArray { $$ = new_node(ConstExpArray, $4, NULL, $2, 0, 0, NULL, NonType); };
ConstInitVal: ConstExp { $$ = new_node(ConstInitVal, NULL, NULL, $1, 0, 0, NULL, NonType); }
            | LC RC { $$ = new_node(ConstInitVal, NULL, NULL, NULL, 0, 0, NULL, NonType); }
            | LC ConstInitVal RC { $$ = new_node(ConstInitVal, NULL, NULL, $2, 0, 0, NULL, NonType); }
            | LC ConstInitVal COMMA ConstInitVal RC { $$ = new_node(ConstInitVal, $4, NULL, $2, 0, 0, NULL, NonType); };
ConstExp: MulExp { $$ = new_node(ConstExp, NULL, NULL, $1, 0, 0, NULL, NonType); }
        | MulExp PLUS Exp { $$ = new_node(ConstExp, $3, NULL, $1, PLUS, 0, NULL, NonType); }
        | MulExp MINUS Exp { $$ = new_node(ConstExp, $3, NULL, $1, MINUS, 0, NULL, NonType); };

VarDecl: INT VarDef SEMICOLON { $$ = new_node(VarDecl, NULL, NULL, $2, 0, 0, NULL, Int); }
       | FLOAT VarDef SEMICOLON { $$ = new_node(VarDecl, NULL, NULL, $2, 0, 0, NULL, Float); };
VarDef: ID ConstExpArray { $$ = new_node(VarDef, NULL, $2, NULL, 0, 0, $1, NonType); }
      | ID ConstExpArray ASSIGN InitVal { $$ = new_node(VarDef, NULL, $2, $4, 0, 0, $1, NonType); }
      | ID ConstExpArray COMMA VarDef { $$ = new_node(VarDef, $4, $2, NULL, 0, 0, $1, NonType); }
      | ID ConstExpArray ASSIGN InitVal COMMA VarDef { $$ = new_node(VarDef, $6, $2, $4, 0, 0, $1, NonType); };
InitVal: Exp { $$ = new_node(InitVal, NULL, NULL, $1, Exp, 0, NULL, NonType); }
       | LC RC { $$ = new_node(InitVal, NULL, NULL, NULL, InitVals, 0, NULL, NonType); }
       | LC InitVals RC { $$ = new_node(InitVal, NULL, NULL, $2, InitVals, 0, NULL, NonType); };
InitVals: InitVal { $$ = new_node(InitVals, NULL, NULL, $1, 0, 0, NULL, NonType); }
        | InitVal COMMA InitVals { $$ = new_node(InitVals, $3, NULL, $1, 0, 0, NULL, NonType); };

FuncDef: INT ID LP RP Block { $$ = new_node(FuncDef, NULL, NULL, $5, 0, 0, $2, Int); }
       | FLOAT ID LP RP Block { $$ = new_node(FuncDef, NULL, NULL, $5, 0, 0, $2, Float); }
       | VOID ID LP RP Block { $$ = new_node(FuncDef, NULL, NULL, $5, 0, 0, $2, Void); }
       | INT ID LP FuncFParam RP Block { $$ = new_node(FuncDef, NULL, $4, $6, 0, 0, $2, Int); }
       | FLOAT ID LP FuncFParam RP Block { $$ = new_node(FuncDef, NULL, $4, $6, 0, 0, $2, Float); }
       | VOID ID LP FuncFParam RP Block { $$ = new_node(FuncDef, NULL, $4, $6, 0, 0, $2, Void); };;
FuncFParam: INT ID { $$ = new_node(FuncFParam, NULL, NULL, NULL, 0, 0, $2, Int); }
          | FLOAT ID { $$ = new_node(FuncFParam, NULL, NULL, NULL, 0, 0, $2, Float); }
          | INT ID LB RB ExpArray { $$ = new_node(FuncFParam, NULL, NULL, $5, 0, 0, $2, Int); }
          | FLOAT ID LB RB ExpArray { $$ = new_node(FuncFParam, NULL, NULL, $5, 0, 0, $2, Float); }
          | INT ID COMMA FuncFParam { $$ = new_node(FuncFParam, $4, NULL, NULL, 0, 0, $2, Int); }
          | FLOAT ID COMMA FuncFParam { $$ = new_node(FuncFParam, $4, NULL, NULL, 0, 0, $2, Float); }
          | INT ID LB RB ExpArray COMMA FuncFParam { $$ = new_node(FuncFParam, $7, NULL, $5, 0, 0, $2, Int); }
          | FLOAT ID LB RB ExpArray COMMA FuncFParam { $$ = new_node(FuncFParam, $7, NULL, $5, 0, 0, $2, Float); };

Block: LC BlockItem RC { $$ = new_node(Block, NULL, NULL, $2, 0, 0, NULL, NonType); };
BlockItem: { $$ = NULL; }
         | ConstDecl BlockItem { $$ = new_node(BlockItem, $2, NULL, $1, 0, 0, NULL, NonType); }
         | VarDecl BlockItem { $$ = new_node(BlockItem, $2, NULL, $1, 0, 0, NULL, NonType); }
         | Stmt BlockItem { $$ = new_node(BlockItem, $2, NULL, $1, 0, 0, NULL, NonType); };

// 以下是你需要完成的语法规则和语义计算规则
//Stmt → LVal '=' Exp ';' | [Exp] ';' | Block
//| 'if' '(' Cond ')' Stmt [ 'else' Stmt ]
//| 'while' '(' Cond ')' Stmt
//| 'break' ';' | 'continue' ';'
//| 'return' [Exp] ';'
Stmt: LVal ASSIGN Exp SEMICOLON {$$ = NULL;}
    | Block {$$ = NULL;}
    | SEMICOLON {$$ = NULL;}
    | Exp SEMICOLON {$$ = NULL;}
    | IF LP Cond RP Stmt ELSE Stmt {$$ = NULL;}
    | IF LP Cond RP Stmt %prec LOWER_THEN_ELSE {$$ = NULL;}
    | WHILE LP Cond RP Stmt {$$ = NULL;}
    | BREAK SEMICOLON {$$ = NULL;}
    | CONTINUE SEMICOLON {$$ = NULL;}
    | RETURN Exp SEMICOLON {$$ = NULL;}
    | RETURN SEMICOLON {$$ = NULL;};


Exp: AddExp { $$ = new_node(Exp, NULL, NULL, $1, 0, 0, NULL, NonType); };
AddExp: MulExp { $$ = new_node(AddExp, NULL, NULL, $1, MUL, 0, NULL, NonType); }
      | MulExp PLUS AddExp { $$ = new_node(AddExp, $3, NULL, $1, PLUS, 0, NULL, NonType); }
      | MulExp MINUS AddExp { $$ = new_node(AddExp, $3, NULL, $1, MINUS, 0, NULL, NonType); };
MulExp: UnaryExp { $$ = new_node(MulExp, NULL, NULL, $1, UnaryExp, 0, NULL, NonType); }
      | UnaryExp MUL MulExp { $$ = new_node(MulExp, $3, NULL, $1, MUL, 0, NULL, NonType); }
      | UnaryExp DIV MulExp { $$ = new_node(MulExp, $3, NULL, $1, DIV, 0, NULL, NonType); }
      | UnaryExp MOD MulExp { $$ = new_node(MulExp, $3, NULL, $1, MOD, 0, NULL, NonType); };

UnaryExp: PrimaryExp { $$ = new_node(UnaryExp, NULL, NULL, $1, PrimaryExp, 0, NULL, NonType); }
        | ID LP RP { $$ = new_node(UnaryExp, NULL, NULL, NULL, FuncRParams, 0, $1, NonType); }
        | ID LP FuncRParams RP { $$ = new_node(UnaryExp, NULL, NULL, $3, FuncRParams, 0, $1, NonType); }
        | PLUS UnaryExp { $$ = new_node(UnaryExp, NULL, NULL, $2, Plus, 0, NULL, NonType); }
        | MINUS UnaryExp { $$ = new_node(UnaryExp, NULL, NULL, $2, Minus, 0, NULL, NonType); }
        | NOT UnaryExp { $$ = new_node(UnaryExp, NULL, NULL, $2, NOT, 0, NULL, NonType); };
FuncRParams: Exp { $$ = new_node(FuncRParams, NULL, NULL, $1, 0, 0, NULL, NonType); }
           | Exp COMMA FuncRParams { $$ = new_node(FuncRParams, $3, NULL, $1, 0, 0, NULL, NonType); };
PrimaryExp: LP Exp RP { $$ = new_node(PrimaryExp, NULL, NULL, $2, Exp, 0, NULL, NonType); }
          | LVal { $$ = new_node(PrimaryExp, NULL, NULL, $1, LVal, 0, NULL, NonType); }
          | INT_LIT { $$ = new_node(PrimaryExp, NULL, NULL, NULL, $1, 0, NULL, Int); }
          | FLOAT_LIT { $$ = new_node(PrimaryExp, NULL, NULL, NULL, 0, $1, NULL, Float); };
LVal: ID ExpArray { $$ = new_node(LVal, NULL, NULL, $2, 0, 0, $1, NonType); };

Cond: LOrExp { $$ = new_node(Cond, NULL, NULL, $1, 0, 0, NULL, NonType); };

LOrExp: LAndExp { $$ = new_node(Cond, NULL, NULL, $1, 0, 0, NULL, NonType); }
      | LAndExp OR LOrExp { $$ = new_node(Cond, $3, NULL, $1, OR, 0, 0, NonType); };

LAndExp: EqExp { $$ = new_node(LAndExp, NULL, NULL, $1, 0, 0, NULL, NonType); }
       | EqExp AND LAndExp { $$ = new_node(LAndExp, $3, NULL, $1, AND, 0, NULL, NonType); };
EqExp: RelExp { $$ = new_node(EqExp, NULL, NULL, $1, 0, 0, NULL, NonType); }
     | RelExp EQ EqExp { $$ = new_node(EqExp, $3, NULL, $1, EQ, 0, NULL, NonType); }
     | RelExp NE EqExp { $$ = new_node(EqExp, $3, NULL, $1, NE, 0, NULL, NonType); };
RelExp: AddExp { $$ = new_node(RelExp, NULL, NULL, $1, 0, 0, NULL, NonType); }
      | AddExp LT RelExp { $$ = new_node(RelExp, $3, NULL, $1, LT, 0, NULL, NonType); }
      | AddExp GT RelExp { $$ = new_node(RelExp, $3, NULL, $1, GT, 0, NULL, NonType); }
      | AddExp LE RelExp { $$ = new_node(RelExp, $3, NULL, $1, LE, 0, NULL, NonType); }
      | AddExp GE RelExp { $$ = new_node(RelExp, $3, NULL, $1, GE, 0, NULL, NonType); };

ExpArray: { $$ = NULL; }
        | LB Exp RB ExpArray { $$ = new_node(ExpArray, $4, NULL, $2, 0, 0, NULL, NonType); };
%%

int main(int argc, char *argv[]) {
    int index = strlen(argv[1]) - 1;
    while(index > 0 && argv[1][index - 1] != '/')
        index--;
    strcpy(filename, argv[1] + index);
    freopen(argv[1], "r", stdin);
    yyparse();
    if (syntax_error == 0) 
        display(root);
    return 0;
}

/*
void yyerror(char *msg) {
    printf("%s:%d\n", name, yylineno);
    printf("error text: %s\n", yytext);
    exit(-1);
}
*/
#include<stdarg.h>
void yyerror(const char* fmt, ...)
{
    syntax_error = 1;    
    va_list ap;
    va_start(ap, fmt);
    fprintf(stderr, "%s:%d ", filename, yylineno);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, ".\n");
}	

