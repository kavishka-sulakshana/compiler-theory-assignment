%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct{
    char id[20];
    int type;
    int int_value;
    float float_value;
}Variable;
Variable vars[100];
int var_count = 0;

Variable *find_var(char *id);

%}
%token TOK_SEMICOLON TOK_ADD TOK_MUL TOK_DOT TOK_INT TOK_FLOAT TOK_MAIN TOK_NUM TOK_PRINTVAR TOK_ID TOK_LCURL TOK_RCURL TOK_EQ
/*all possible types*/
%union{
    int int_val;
    float float_val;
    char str_val[20];
    Variable *var;
}

%type <int_val> TOK_NUM Integer
%type <float_val> Float
%type <var> E
%type <str_val> TOK_ID

/*left associative*/
%left TOK_ADD
%left TOK_MUL
%%
prog : TOK_MAIN TOK_LCURL stmts TOK_RCURL
stmts : | stmt TOK_SEMICOLON stmts
stmt : TOK_INT TOK_ID {
    Variable var = {.type = 0, .int_value = 0};
    strcpy(var.id, $2);
    vars[var_count++] = var;
}
 | TOK_FLOAT TOK_ID {
    Variable var = {.type = 1, .float_value = 0};
    strcpy(var.id, $2);
    vars[var_count++] = var;
 }
 | TOK_ID TOK_EQ E {
    Variable *var = find_var($1);
    Variable *var2 = find_var($3);
    if(var == NULL){
        fprintf(stderr, "Variable %s not declared\n", $1);
        exit(1);
    }
    if(var2 == NULL)
    {
        if(var->type == 0)
            var->int_value = atoi($3);
        else
            var->float_value = atof($3);
    }else{
        if(var->type != var2->type)
        {
            fprintf(stderr, "Type mismatch\n");
            exit(1);
        }
        if(var->type == 0)
            var->int_value = var2->int_value;
        else
            var->float_value = var2->float_value;
    }
 }
 | TOK_PRINTVAR TOK_ID {
    Variable *var = find_var($2);
    if(var == NULL)
    {
        fprintf(stderr, "Variable %s not declared\n", $2);
        exit(1);
    }
    if(var->type == 0)
        printf("%d\n", var->int_value);
    else
        printf("%f\n", var->float_value);
 }
E : Integer {$$ = $1;}
 | Float {$$ = $1;}
 | TOK_ID {
    Variable *var = find_var($1);
    if(var == NULL)
    {
        fprintf(stderr, "Variable %s not declared\n", $1);
        exit(1);
    }
    if(var->type == 0)
        $$ = var->int_value;
    else
        $$ = var->float_value;
 }
 | E TOK_ADD E {$$ = $1 + $3;}
 | E TOK_MUL E {$$ = $1 * $3;}
Integer : TOK_NUM {$$ = atoi($1);}
Float : Integer TOK_DOT Integer {
    char str[20];
    sprintf(str, "%d.%d", $1, $3);
    $$ = atof(str);
}
%%
int yyerror(char *s)
{
    fprintf(stderr, "syntax error");
    return 0; 
}

int main()
{
    yyparse();
    return 0;
}

Variable *find_var(char *id)
{
    int i;
    for(i = 0; i < var_count; i++)
    {
        if(strcmp(vars[i].id, id) == 0)
            return &vars[i];
    }
    return NULL;
}
