%{
	#include <time.h>
	#include <stdlib.h>
	typedef long long YYSTYPE;
	extern char default_output_fmt;
	#define YYSTYPE_IS_DECLARED
	#define YY_NO_UNPUT
	#include "hexcalc.h"
	#include "hexcalc.tab.h"
%}

%%
	/* integers */

[0-9]+	{
	yylval = strtoll(yytext, NULL, 0);
		return INTEGER;
	}
'[[:print:]]' {
		yylval = yytext[1];
		return INTEGER;
	}

	/*
	[0-9a-fA-F]+ {
			yylval = strtoll(yytext, NULL, 16);
			return INTEGER;
		}
	*/

0x[0-9a-fA-F_]+ {
		char *p = yytext;
		int i;
		/* allow _ in numbers to seperate digit chunks */
		for (i=0; *p; i++, p++) {
			if (yytext[i] == '_') {
				p++;
			}
			yytext[i] = *p;
		}
		yytext[i] = '\0';
		yylval = strtoll(yytext, NULL, 0);
		return INTEGER;
	}

0b[01]+ {
		/* yytext + 2 skips '0b' prefix */
		yylval = strtoll(yytext + 2, NULL, 2);
		return INTEGER;
	}

[0-9]+:[0-9]+ {
		struct tm tm;
		strptime(yytext, "%H:%M", &tm);
		yylval = (tm.tm_hour * 60) + tm.tm_min;
		return INTEGER;
	}


	/* operators */

[-+&|^()*/%~!'] {
		return *yytext;
	}


[<]{2}	{
		return SHR;
	}

[>]{2}	{
		return SHL;
	}

	/* format specifiers */

[dbxotca]	{
		yylval = *yytext;
		return FORMAT;
	}

[s]	{
		yylval = *yytext;
		return SIGNED;
	}



[ \t] 	;

.	yyerror("invalid character");

%%

void scan_string(char *s)
{
	yy_scan_string(s);
}

int yywrap(void){
	return 1;
}
