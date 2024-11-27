%{
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include "parser.tab.h"
%}

%% 
"("            { return LP;}
")"            { return RP;}
":="            { return ASGN;}
";"            { return SC;}
"*"|"div"|"mod"        { yylval.op2 = malloc(strlen(yytext));
                        strcpy(yylval.op2, yytext); 
                        return OP2;}
"+"|"-"            { yylval.op3 = malloc(strlen(yytext));
                    strcpy(yylval.op3, yytext);
                    return OP3;}
"="|"!="|"<"|">"|"<="|">="    { yylval.op4 = malloc(strlen(yytext));
                                strcpy(yylval.op4, yytext);
                                return OP4;}
"if"            { return IF;}
"then"             { return THEN;}
"else"            { return ELSE;}
"begn"            { return BEGN;}
"end"            { return END;}
"while"            { return WHILE;}
"do"            { return DO;}
"program"        { return PROGRAM;}
"var"             { return VAR;}
"as"            { return AS;}
"int"             {  return INT;}
"bool"             { return BOOL;}
"writeInt"         { return WRITEINT;}
"readInt"         { return READINT;}
([1-9][0-9]*|0)   { 
                    errno = 0;
                    long result = strtol(yytext, NULL, 10);
                    if (errno == ERANGE || result < INT_MIN || result > INT_MAX) {
                        fprintf(stderr, "ERROR: Number \'%s\' is out of range for type int\n", yytext);
                        exit(EXIT_FAILURE);
                    }
                    yylval.num = malloc(sizeof(int));
                    *yylval.num = (int)result;
                    printf("yylval.num: %d\n", *yylval.num);
                    return num;}
false|true       {
    // TODO: remove fprintf(yyout, "boollit\t\t%s\n", yytext); 
    yylval.boollit = malloc(strlen(yytext)); 
    strcpy(yylval.boollit, yytext); 
    return boollit;}
[A-Z][A-Z0-9]*  {
    // TODO: remove fprintf(yyout, "ident\t\t%s\n", yytext);
    yylval.sval = malloc(strlen(yytext)); 
    strcpy(yylval.sval, yytext); 
    return ident;
}
<<EOF>>        {return 0;}
"%"[^\n]*     {/* ignore comments */}
[ \t\n]+        {/* ignore whitespace */}
.            {yyerror("INVALID CHARACTER");}
[^ \t\n]+        {yyerror(yytext);}
%%

