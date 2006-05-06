#include <stdio.h>
#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>

char default_output_fmt;
int yyparse(void);

int main(int argc, char *argv[]){
	static char*line_read = (char *)NULL;
	if (argc > 1)
		default_output_fmt = argv[1][0];
	else 
		default_output_fmt = 'x';
	while(1){
		if (line_read) {
			free(line_read);
			line_read = (char *)NULL;
		}

		line_read = readline("");
		if (!line_read)
			break;
		
		if (*line_read)
			add_history(line_read);
		yy_scan_string(line_read);
		yyparse();
	}
}
