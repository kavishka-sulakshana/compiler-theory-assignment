%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int line_no; 

struct variable{ 
    char id[20];
    int type;
    int int_value;
    float float_value;
};

struct tree_node{
    int type;
    int int_value;
    float float_value;
};

struct variable vars[100];
int var_count = 0;

struct variable *find_var(char *id);
struct variable *createVar(char *id, int type);
struct tree_node *createTreeNode(int type);
void errorMessage(int position);

%}
%token TOK_SEMICOLON TOK_ADD TOK_MUL TOK_DOT TOK_INT TOK_FLOAT TOK_MAIN TOK_NUM TOK_PRINTVAR TOK_ID TOK_LCURL TOK_RCURL TOK_EQ

%union{
    int int_val;
    struct variable *var;
    char str[20];
    struct tree_node *e;
}

%type <int_val> TOK_NUM
%type <str> TOK_ID 
%type <e> E

/*left associative*/
%left TOK_ADD
%left TOK_MUL
%%
prog : TOK_MAIN TOK_LCURL stmts TOK_RCURL
stmts : | stmt TOK_SEMICOLON stmts
stmt : TOK_INT TOK_ID { 
    char *id = malloc(sizeof(char) * 20);
    // printf("id %s \n", $2);
    strcpy(id, $2);
    struct variable *var = createVar(id, 0);
    vars[var_count] = *var;
    var_count++;
}
 | TOK_FLOAT TOK_ID { 
    char *id = malloc(sizeof(char) * 20);
    strcpy(id, $2);
    struct variable *var = createVar(id, 1);
    vars[var_count] = *var;
    var_count++;
 }
 | TOK_ID TOK_EQ E { 
    struct variable *var1 = find_var($1);
    // printf("variable %s \n", $1);
    if(var1 == NULL)
    {
        fprintf(stderr, "%s is used but not declared \n", $1);
        exit(1);
    }
    if(var1->type == 0 && $3->type == 0)
        var1->int_value = $3->int_value;
    else if(var1->type == 0 && $3->type == 1){
        fprintf(stderr, "Declared type int but given float\n");
        exit(1);
        // var1->int_value = $3->float_value;
    }
    else if(var1->type == 1 && $3->type == 0)
        var1->float_value = $3->int_value;
    else if(var1->type == 1 && $3->type == 1)
        var1->float_value = $3->float_value;
 }
 | TOK_PRINTVAR TOK_ID { //corr
    struct variable *var1 = find_var($2);
    // fprintf(stderr, "variable %s ", $2);
    if(var1 == NULL)
    {
        fprintf(stderr, "%s used but not declared \n", $2);
        exit(1);
    }
    if(var1->type == 0)
        printf("%d", var1->int_value);
    else
        printf("%f", var1->float_value);
 }
E : TOK_NUM { 
    struct tree_node *e = createTreeNode(0);
    e->int_value = $1;
    $$ = e;
}
 | TOK_NUM TOK_DOT TOK_NUM {
    char str[20];
    sprintf(str, "%d.%d", $1, $3);
    struct tree_node *e = createTreeNode(1);
    e->float_value = atof(str);
    $$ = e;
 } 
 | TOK_ID {
    struct variable *var = find_var($1);
    if(var == NULL)
    {
        fprintf(stderr, "%s is used but not declared \n", $1);
        exit(1);
    }
    else if(var->type == 0)
    {
        struct tree_node *e = createTreeNode(0);
        e->int_value = var->int_value;
        $$ = e;
    }
    else
    {
        struct tree_node *e = createTreeNode(1);
        e->float_value = var->float_value;
        $$ = e;
    }
 }
 | E TOK_ADD E {
    if($1->type == 0 && $3->type == 0)
    {
        struct tree_node *e = createTreeNode(0);
        e->int_value = $1->int_value + $3->int_value;
        $$ = e;
    }
    else if($1->type == 0 && $3->type == 1)
    {
        struct tree_node *e = createTreeNode(1);
        e->float_value = $1->int_value + $3->float_value;
        $$ = e;
    }
    else if($1->type == 1 && $3->type == 0)
    {
        struct tree_node *e = createTreeNode(1);
        e->float_value = $1->float_value + $3->int_value;
        $$ = e;
    }
    else
    {
        struct tree_node *e = createTreeNode(1);
        e->float_value = $1->float_value + $3->float_value;
        $$ = e;
    }    
 }
 | E TOK_MUL E {
    if($1->type == 0 && $3->type == 0)
    {
        struct tree_node *e = createTreeNode(0);
        e->int_value = $1->int_value * $3->int_value;
        $$ = e;
    }
    else if($1->type == 0 && $3->type == 1)
    {
        struct tree_node *e = createTreeNode(1);
        e->float_value = $1->int_value * $3->float_value;
        $$ = e;
    }
    else if($1->type == 1 && $3->type == 0)
    {
        struct tree_node *e = createTreeNode(1);
        e->float_value = $1->float_value * $3->int_value;
        $$ = e;
    }
    else
    {
        struct tree_node *e = createTreeNode(1);
        e->float_value = $1->float_value * $3->float_value;
        $$ = e;
    }
 }
%%
int yyerror(char *s)
{
    fprintf(stderr, "syntax error");
    errorMessage(line_no);
    return 0; 
}

int main()
{
    yyparse();
    return 0;
}

struct variable *find_var(char *id)
{
    int i;
    for(i = 0; i < var_count; i++)
    {
        if(strcmp(vars[i].id, id) == 0)
            return &vars[i];
    }
    return NULL;
}

struct tree_node *createTreeNode(int type)
{
    struct tree_node *node = malloc(sizeof(struct tree_node));
    node->type = type;
    return node;
}

struct variable *createVar(char *id, int type)
{
    struct variable *var = malloc(sizeof(struct variable));
    strcpy(var->id, id);
    var->type = type;
    if(type == 0)
        var->int_value = 0;
    else
        var->float_value = 0;
    return var;
}

void errorMessage(int position){
    printf("Syntax Error in line %d\n", position);
}