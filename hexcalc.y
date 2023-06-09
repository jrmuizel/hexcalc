%token INTEGER
%token SIGNED
%token FORMAT
%left '|'
%left '^'
%left '&'
%left SHR SHL
%left '+' '-' '\''
%left '*' '/' '%'
%left '~' '!'
%left 'd' 'b' 'h' 'o'

%{
	#define YYERROR_VERBOSE
	#define _ISOC9X_SOURCE
	#include <stdlib.h>
	#include <stdio.h>
	#include "hexcalc.h"
	#include "lex.yy.h"
	typedef long long YYSTYPE;
	#define YYSTYPE_IS_DECLARED
	extern char default_output_fmt;
	long long ans;
	void bin_print(long long);
	void print_value(char format, long long value);

%}
%%

program:
	statement
	|
	;

statement:
	fexpr		{ print_value(default_output_fmt, $1); ans = $1;}
	| FORMAT fexpr	{ 
				print_value($1, $2);
				ans = $2;
			}

	| FORMAT	{	print_value($1, ans);	}
;

fexpr:
	'%' expr		{ $$ = ans % $2;}
	| '+' expr		{ $$ = ans + $2; }
	| '-' expr		{ $$ = ans - $2; }
	| '*' expr		{ $$ = ans * $2; }
	| '/' expr		{ $$ = ans / $2; }
	| '&' expr		{ $$ = ans & $2; }
	| '|' expr		{ $$ = ans | $2; }
	| '^' expr		{ $$ = ans ^ $2; }
	| '~'		{ $$ = ~ans; }
	| '!'		{ $$ = !ans; }
	| SHR expr		{ $$ = ans << $2; }
	| SHL expr		{ $$ = ans >> $2; }
	| '\'' expr	{ $$ = llabs(ans - $2); }
	| expr { $$ = $1; }
	;

expr:
	INTEGER
	| '%'			{ $$ = ans; } // '%' represents the last value
	| expr '%' expr		{ $$ = $1 % $3; }
	| expr '+' expr		{ $$ = $1 + $3; }
	| expr '-' expr		{ $$ = $1 - $3; }
	| expr '*' expr		{ $$ = $1 * $3; }
	| expr '/' expr		{ $$ = $1 / $3; }
	| expr '&' expr		{ $$ = $1 & $3; }
	| expr '|' expr		{ $$ = $1 | $3; }
	| expr '^' expr		{ $$ = $1 ^ $3; }
	| '~' expr		{ $$ = ~$2; }
	| '!' expr		{ $$ = !$2; }
	| expr SHR expr		{ $$ = $1 << $3; }
	| expr SHL expr		{ $$ = $1 >> $3; }
	| '(' expr ')'		{ $$ = $2; }
	| expr '\'' expr	{ $$ = llabs($1 - $3); }
	;
%%


void print_value(char format, long long value)
{
	switch(format) {
		case 'd':	/* decimal */
			if (value <= 0xffffffff)
				printf("%d\n", (int)value);
			else
				printf("%lld\n", value);
			break;
		case 'b':	/* binary */
			bin_print(value);
			break;
		case 'x':	/* hex */
			printf("0x%llx\n", value);
			break;
		case 'a':	/* hex */
			if (value <= 0xffffffff) {
				if (value > 0x10000000) {
					printf("-0x%x\n", -((int)value));
				} else {
					printf("0x%llx\n", value);
				}
			} else {
				printf("0x%llx\n", value);
			}
			break;
		case 'o':	/* octal */
			printf("0x%llo\n", value);
			break;
		case 't':	/* time */
			printf("%lld:%02lld\n", value/60, llabs(value%60));
			break;
		case 'c':
			printf("%c\n", (char)value);
			break;
	}
}

void bin_print(long long x){
	/* we want to print at least the bottom bit */
	int bit_count = 1;
	int int_size;
	int_size = sizeof(long long) * 8;

	/* determine the highest bit */
	for (int i=0; i<int_size; i++) {
		if (x & (1ULL << i)) {
			bit_count = i+1;
		}
	}
	/* round up to the nearest multiple of 4 */
	bit_count = ((bit_count + (4-1)) & -4);

	for(int i=0; i<bit_count; i++){
		if (x & (1ULL << (bit_count-1)))
			putchar('1');
		else
			putchar('0');
		if ((i % 4) == 3)
			putchar(' ');
		x <<= 1;
	}
	printf("\n");
}



#include <stdio.h>
#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>

char default_output_fmt;
int yyparse(void);

int yyerror(char *s)
{
	printf("%s\n", s);
	return 0;
}

int main(int argc, char *argv[])
{
	char *line_read = NULL;

	if (argc > 1)
		default_output_fmt = argv[1][0];
	else
		default_output_fmt = 'x';

	while (1) {
		if (line_read) {
			free(line_read);
			line_read = NULL;
		}

		line_read = readline("");
		if (!line_read)
			break;

		if (*line_read)
			add_history(line_read);
		scan_string(line_read);
		yyparse();
	}
	return 0;
}
