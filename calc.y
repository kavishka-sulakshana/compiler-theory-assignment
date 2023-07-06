%{
#include <stdio.h>
%}
%token TOK_SEMICOLON TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_NUM TOK_PRINTLN
/*all possible types*/
%union{
int int_val;
}
%type <int_val> expr TOK_NUM

/*left associative*/
%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV
%%
expr_stmt: expr TOK_SEMICOLON
| expr TOK_SEMICOLON expr_stmt 
| TOK_PRINTLN expr TOK_SEMICOLON
{ fprintf(stdout, "the value is %d\n", $2); }
expr: 
expr TOK_ADD expr
{ $$ = $1 + $3; }
| expr TOK_SUB expr
{ $$ = $1 - $3; }
| expr TOK_MUL expr
{ $$ = $1 * $3; }
| TOK_NUM
%%

int main()
{
yyparse();
return 0;
}

int yyerror(char *s)
{
    fprintf(stderr, "error: %s\n", s);
    return 0;
}

