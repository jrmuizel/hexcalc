%token INTEGER
%token SIGNED
%token FORMAT
%token SHL
%token SHR
%left SHR SHL
%left '+' '-' '\''
%left '*' '/' '%'
%left '|'
%left '^'
%left '&'
%left '~' '!'
%left 'd' 'b' 'h' 'o'

%{
	#define YYERROR_VERBOSE
	#define _ISOC9X_SOURCE
	#include <stdlib.h>
	#include <stdio.h>
	typedef long long YYSTYPE;
	#define YYSTYPE_IS_DECLARED
	extern char default_output_fmt;
	long long ans;
	void bin_print(long long);
	void print_value(char format, long long value);
%}
%%

program:
	program statement
	|
	;

statement:
	iexpr		{ print_value(default_output_fmt, $1); ans = $1;}
	| FORMAT iexpr	{ 
				print_value($1, $2);
				ans = $2;
			}

	| FORMAT	{	print_value($1, ans);	}
;

iexpr: 
	expr { $$ = $1; }
	;

expr:
	INTEGER
	| expr '%' expr		{ $$ = $1 % $3;}
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
				printf("%ld\n", (int)value);
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
					printf("-0x%lx\n", -((int)value));
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
	int i;
	int j;
	int  k;
	int int_size;
	int_size = sizeof(long long) * 8;
	/* determine the highest bit */

	for(j=0; j<int_size; j++){
		if (x & (1ULL << j)) {
			k = j;
		}
	}

	for(i=k; i>=0; i--){
		if(x & (1ULL << i))
			printf("1");
		else
			printf("0");
	}
	printf("\n");
}

int yyerror(char *s) {
	printf("%s\n", s);
	return 0;
}

