LIBS = -lreadline
CFLAGS = -ggdb3

hexcalc: main.c hexcalc.tab.c lex.yy.c
	gcc $(CFLAGS) -o hexcalc $(LIBS) main.c hexcalc.tab.c lex.yy.c

hexcalc.tab.c: hexcalc.y
	bison -d hexcalc.y

hexcalc.tab.h: hexcalc.tab.c

lex.yy.c: hexcalc.lex hexcalc.tab.h
	flex hexcalc.lex

clean:
	-rm -f hexcalc *.o y.tab.h y.tab.c lex.yy.c
