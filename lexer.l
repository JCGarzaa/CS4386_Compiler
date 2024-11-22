%{
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include "parser.tab.h"
%}

%% 
"("            {fprintf(yyout, "LP\t\t%s\n", yytext); return LP;}
")"            {fprintf(yyout, "RP\t\t%s\n", yytext); return RP;}
":="            {fprintf(yyout, "ASGN\t\t%s\n", yytext); return ASGN;}
";"            {fprintf(yyout, "SC\t\t%s\n", yytext); return SC;}
"*"|"div"|"mod"        {fprintf(yyout, "OP2\t\t%s\n", yytext); return OP2;}
"+"|"-"            {fprintf(yyout, "OP3\t\t%s\n", yytext); return OP3;}
"="|"!="|"<"|">"|"<="|">="    {fprintf(yyout, "OP4\t\t%s\n", yytext); return OP4;}
"if"            {fprintf(yyout, "IF\t\t%s\n", yytext); return IF;}
"then"             {fprintf(yyout, "THEN\t\t%s\n", yytext); return THEN;}
"else"            {fprintf(yyout, "ELSE\t\t%s\n", yytext); return ELSE;}
"begn"            {fprintf(yyout, "BEGIN\t\t%s\n", yytext); return BEGN;}
"end"            {fprintf(yyout, "END\t\t%s\n", yytext); return END;}
"while"            {fprintf(yyout, "WHILE\t\t%s\n", yytext); return WHILE;}
"do"            {fprintf(yyout, "DO\t\t%s\n", yytext); return DO;}
"program"        {fprintf(yyout, "PROGRAM\t\t%s\n", yytext); return PROGRAM;}
"var"             {fprintf(yyout, "VAR\t\t%s\n", yytext); return VAR;}
"as"            {fprintf(yyout, "AS\t\t%s\n", yytext); return AS;}
"int"             {fprintf(yyout, "INT\t\t%s\n", yytext);  return INT;}
"bool"             {fprintf(yyout, "BOOL\t\t%s\n", yytext); return BOOL;}
"writeInt"         {fprintf(yyout, "WRITEINT\t\t%s\n", yytext); return WRITEINT;}
"readInt"         {fprintf(yyout, "READINT\t\t%s\n", yytext); return READINT;}
([1-9][0-9]*|0)   {fprintf(yyout, "num\t\t%s\n", yytext); 
                    errno = 0;
                    long result = strtol(yytext, NULL, 10);
                    if (errno == ERANGE) {
                        if (result == LONG_MAX) {
                            printf("Overflow: Value too large for a long\n");
                        } else if (result == LONG_MIN) {
                            printf("Underflow: Value too small for a long\n");
                        }
                    }
                    yylval.num = result;
                    return num;}
false|true       {
    fprintf(yyout, "boollit\t\t%s\n", yytext); 
    yylval.boollit = malloc(strlen(yytext)); 
    strcpy(yylval.boollit, yytext); 
    return boollit;}
[A-Z][A-Z0-9]*  {
    fprintf(yyout, "ident\t\t%s\n", yytext);
    yylval.sval = malloc(strlen(yytext)); 
    strcpy(yylval.sval, yytext); 
    return ident;
}
<<EOF>>        {return 0;}
"%"[^\n]*     {/* ignore comments */}
[ \t\n]+        {/* ignore whitespace */}
.            {yyerror("INVALID CHARACTER");}
[^ \t\n]+        {yyerror("INVALID TOKEN");}
%%

