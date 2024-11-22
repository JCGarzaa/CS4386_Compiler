%{
#include <stdio.h>
#include <stdlib.h>
#include "structs.h"
extern FILE *yyin, *yyout;
void yyerror(char *s);
%}

// symbols
%union {
  char *sval;
  struct Program* program;
  struct Declarations* declarations;
  struct Type* type;
  struct StatementSequence* stmtSeq;
  struct Statement* stmt;
  struct Assignment* assignment;
  struct IfStatement* ifStmt;
  struct WhileStatement* whileStmt;
  struct WriteInt* writeInt;
  struct Expression* expression;
  struct ElseClause* elseClause;
  struct SimpleExpression* simpleExpression;
  struct Term* term;
  struct Factor* factor;
  long num;
  char* boollit;

};
%token PROGRAM
%token VAR
%token BEGN
%token END
%token IF
%token THEN
%token ELSE
%token WHILE
%token DO
%token WRITEINT
%token READINT
%token AS
%token SC
%token OP2
%token OP3
%token OP4
%token ASGN
%token INT
%token BOOL
%token <sval> ident
%token <sval> num
%token boollit
%token LP
%token RP

%type <program> program
%type <declarations> declarations
%type <type> type
%type <stmtSeq> statementSequence
%type <stmt> statement
%type <assignment> assignment
%type <ifStmt> ifStatement
%type <whileStmt> whileStatement
%type <writeInt> writeInt
%type <expression> expression
%type <elseClause> elseClause
%type <simpleExpression> simpleExpression
%type <term> term
%type <factor> factor
// %type <num> num
%type <boollit> boollit


%start program
%%
program: 
       PROGRAM declarations BEGN statementSequence END { struct Program* ptr = malloc(sizeof(struct Program));
                                                       ptr->decl = $2;
                                                       ptr->stmtSeq = $4;
                                                       $$ = ptr; }
       ;

declarations:
            VAR ident AS type SC declarations { struct Declarations* ptr = malloc(sizeof(struct Declarations));
                                                ptr->ident = $2;
                                                ptr->type = $4;
                                                ptr->decl = $6;
                                                $$ = ptr; }
            | /* empty */ { $$ = (struct Declarations*)NULL; }
            ;

type:
    INT { struct Type* ptr = malloc(sizeof(struct Type));
          ptr->type = "int";
          $$ = ptr; }
    | BOOL { struct Type* ptr = malloc(sizeof(struct Type));
            ptr->type = "bool";
            $$ = ptr; }
    ;

statementSequence:
                 statement SC statementSequence { struct StatementSequence* ptr = malloc(sizeof(struct StatementSequence));
                                                  ptr->stmt = $1;
                                                  ptr->stmtSeq = $3;
                                                  $$ = ptr; }
                 | /* empty */ { $$ = (struct StatementSequence*)NULL; }
                 ;

statement:
         assignment { struct Statement* ptr = malloc(sizeof(struct Statement));
                      ptr->assignment = $1;
                      $$ = ptr; }
         | ifStatement { struct Statement* ptr = malloc(sizeof(struct Statement));
                         ptr->ifStmt = $1;
                         $$ = ptr; }
         | whileStatement { struct Statement* ptr = malloc(sizeof(struct Statement));
                            ptr->whileStmt = $1;
                            $$ = ptr; }
         | writeInt { struct Statement* ptr = malloc(sizeof(struct Statement));
                      ptr->writeInt = $1;
                      $$ = ptr; }
         ;

assignment: 
          ident ASGN expression { struct Assignment* ptr = malloc(sizeof(struct Assignment));
                                  ptr->ident = $1;
                                  ptr->expr = $3;
                                  $$ = ptr; }
          | ident ASGN READINT { struct Assignment* ptr = malloc(sizeof(struct Assignment));
                                 ptr->ident = $1;
                                 ptr->expr = (struct Expression*)NULL;
                                 $$ = ptr; }
          ;

ifStatement:
           IF expression THEN statementSequence elseClause END {
             struct IfStatement* ptr = malloc(sizeof(struct IfStatement));
             // printf("ifStatement: \n"); // FIX: REMOVE
             ptr->expr = $2;
             // printf("\texpr in if\n");  // FIX: REMOVE
             ptr->stmtSeq = $4;
             ptr->elseClause = $5;
             $$ = ptr; }
           ;

elseClause:
          ELSE statementSequence { struct ElseClause* ptr = malloc(sizeof(struct ElseClause));
                                    ptr->stmtSeq = $2;
                                    $$ = ptr; }
          | /* empty */ { $$ = (struct ElseClause*)NULL; }
          ;

whileStatement:
              WHILE expression DO statementSequence END { 
                struct WhileStatement* ptr = malloc(sizeof(struct WhileStatement)); 
                ptr->expr = $2;
                ptr->stmtSeq = $4;
                $$ = ptr; }
              ;

writeInt:
        WRITEINT expression { struct WriteInt* ptr = malloc(sizeof(struct WriteInt));
                              ptr->expr = $2;
                              $$ = ptr;}
        ;

expression:
          simpleExpression { struct Expression* ptr = malloc(sizeof(struct Expression));
                             ptr->simpleExpr1 = $1;
                             // ptr->op4 = (char*)NULL; // TODO: MAYBE CHANGE THIS
                             ptr->simpleExpr2 = (struct SimpleExpression*)NULL;
                             $$ = ptr; }
          | simpleExpression OP4 simpleExpression { 
                struct Expression* ptr = malloc(sizeof(struct Expression));
                ptr->simpleExpr1 = $1;
                // ptr->op4 = $2; // TODO: MAYBE CHANGE THIS
                ptr->simpleExpr2 = $3;
                // printf ("simple expression 2: %s\n", ptr->simpleExpr2); // FIX: remove
                $$ = ptr; }
          ;

simpleExpression:
                term OP3 term { struct SimpleExpression* ptr = malloc(sizeof(struct SimpleExpression));
                                ptr->term1 = $1;
                                // ptr->op3 = (char*)NULL; // TODO: MAYBE CHANGE THIS
                                ptr->term2 = $3;
                                $$ = ptr; }
                | term { struct SimpleExpression* ptr = malloc(sizeof(struct SimpleExpression));
                         ptr->term1 = $1;
                         // ptr->op3 = (char*)NULL; // TODO: MAYBE CHANGE THIS
                         ptr->term2 = (struct Term*)NULL;
                         $$ = ptr; }
                ;

term:
    factor OP2 factor { struct Term* ptr = malloc(sizeof(struct Term));
                        ptr->factor1 = $1;
                        // ptr->op2 = (char*)NULL; // TODO: MAYBE CHANGE THIS
                        ptr->factor2 = (struct Factor*)NULL;
                        $$ = ptr; }
    | factor { struct Term* ptr = malloc(sizeof(struct Term));
               ptr->factor1 = $1;
               // ptr->op2 = (char*)NULL; // TODO: MAYBE CHANGE THIS
               ptr->factor2 = (struct Factor*)NULL;
               $$ = ptr;}
    ;

factor:
      ident { struct Factor* ptr = malloc(sizeof(struct Factor));
              ptr->ident = (char*)$1;
              $$ = ptr;}
      | num { struct Factor* ptr = malloc(sizeof(struct Factor));
              ptr->num = $1;
              $$ = ptr;}
      | boollit { struct Factor* ptr = malloc(sizeof(struct Factor));
                  ptr->bool = $1;
                  $$ = ptr;}
      | LP expression RP { struct Factor* ptr = malloc(sizeof(struct Factor));
                           ptr->expr = $2;
                           $$ = ptr;}
      ;
%%

void yyerror(char *s) {
    fprintf(stderr, "yyerror: %s\n", s);
}

int main() {
    yyin = fopen("input.txt", "r");
    yyout = fopen("output.txt", "w");
    int parseResult = yyparse();
    if (parseResult == 0) printf("---SUCCESS---\n");
    else printf("---FAILURE---\n");
    return 0;
}
