## compiler-theory-assignment

> Compile your code

`flex –l calc.l` <br>
`bison -dv calc.y` <br>
`gcc -o calc calc.tab.c lex.yy.c –lfl` <br>
`./calc`
