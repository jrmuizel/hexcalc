LIBS = -lreadline
CFLAGS = -ggdb3 -Wall -D_XOPEN_SOURCE -std=gnu99

hexcalc: hexcalc.tab.c lex.yy.c
	gcc $(CFLAGS) -o hexcalc $(LIBS) hexcalc.tab.c lex.yy.c

hexcalc.tab.c: hexcalc.y
	bison -d hexcalc.y

hexcalc.tab.h: hexcalc.tab.c

lex.yy.c: hexcalc.lex hexcalc.tab.h
	flex hexcalc.lex

clean:
	-rm -f hexcalc *.o hexcalc.tab.h hexcalc.tab.c lex.yy.c
