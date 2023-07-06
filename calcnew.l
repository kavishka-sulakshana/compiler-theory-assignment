%{
#include <stdio.h>
#include <string.h>
#include "calcnew.tab.h"
int line_no = 1;
void errorMessage(char,int);
%}
digit [0-9]
id [a-z]+[0-9]*
skip [ \t]
%%
"main()" { return(TOK_MAIN); }
"int" { return(TOK_INT);}
"float" { return(TOK_FLOAT); }
"printvar" {return(TOK_PRINTVAR);}
{digit}+ { yylval.int_val = atoi(yytext);return (TOK_NUM); }
{id} { strcpy(yylval.str_val, yytext); return (TOK_ID); }
";" { return(TOK_SEMICOLON); }
"+" { return(TOK_ADD); }
"*" { return(TOK_MUL); }
"." { return(TOK_DOT); }
"=" { return(TOK_EQ); }
"{" { return(TOK_LCURL); }
"}" { return(TOK_RCURL); }
{skip} {}
\n {line_no++;}
. {errorMessage(yytext[0], 0);}
%%
void errorMessage(char character, int position){
    printf("Invalid Character '%c' in line %d\n", character, position);
}
int yywrap(){
    return 1;
}