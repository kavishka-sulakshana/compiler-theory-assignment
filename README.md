## compiler-theory-assignment
> Contributers

- Janidu Indusara - [axis0047](https://github.com/axis0047)
- Kavishka Sulakshana - me
  
> Compile your code

`flex –l calc.l` <br>
`bison -dv calc.y` <br>
`gcc -o calc calc.tab.c lex.yy.c –lfl` <br>
`./calc`
