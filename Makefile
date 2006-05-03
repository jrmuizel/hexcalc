LIBS = -lreadline

hexcalc: main.c y.tab.c lex.yy.c
	gcc -Wall -o hexcalc $(LIBS) main.c y.tab.c lex.yy.c

y.tab.c: hexcalc.y
	bison.yacc -d hexcalc.y

y.tab.h: y.tab.c

lex.yy.c: hexcalc.lex y.tab.h
	lex hexcalc.lex

clean:
	-rm -f hexcalc *.o y.tab.h y.tab.c lex.yy.c
