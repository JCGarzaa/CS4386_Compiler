%{
#include <stdio.h>
#include <stdlib.h>
#include "structs.h"
#include "symbol_table.h"

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
  int* num;
  char* boollit;
  char* op2;
  char* op3;
  char* op4;
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
%token <op2> OP2
%token <op3> OP3
%token <op4> OP4
%token ASGN
%token INT
%token BOOL
%token <sval> ident
%token <num> num
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
                                                       $$ = ptr; 
                                                       genCode($2, $4); }
       ;

declarations:
            VAR ident AS type SC declarations { 
                // check if variable declared
                struct SymbolTableEntry *entry = find_variable($2);
                if (entry != NULL) {
                    // variable already declared
                    fprintf(stderr, "ERROR: Variable '%s' has already been declared\n", $2);
                    yyerror("ERROR: Variable already declared.");
                    exit(EXIT_FAILURE);
                }
                add_variable($2, $4, 0);
                struct Declarations* ptr = malloc(sizeof(struct Declarations));
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
          ident ASGN expression { 
            SymbolTableEntry *entry = find_variable($1);
            if (!entry) {
                fprintf(stderr, "ERROR: variable '%s' not declared yet\n", $1);
                yyerror("ERROR: variable not declared yet");
                exit(EXIT_FAILURE);
            }
            initialize_variable($1);
            struct Assignment* ptr = malloc(sizeof(struct Assignment));
            ptr->ident = $1;
            ptr->expr = $3;
            $$ = ptr;
          }
          | ident ASGN READINT { 
                SymbolTableEntry *entry = find_variable($1);
                if (!entry) {
                    fprintf(stderr, "ERROR: variable '%s' not declared yet\n", $1);
                    yyerror("ERROR: variable not declared yet");
                    exit(EXIT_FAILURE);
                }
                initialize_variable($1);
                struct Assignment* ptr = malloc(sizeof(struct Assignment));
                ptr->ident = $1;
                ptr->expr = (struct Expression*)NULL;
                $$ = ptr;
            }
          ;

ifStatement:
           IF expression THEN statementSequence elseClause END {
             struct IfStatement* ptr = malloc(sizeof(struct IfStatement));
             ptr->expr = $2;
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
                             ptr->op4 = (char*)NULL;
                             ptr->simpleExpr2 = (struct SimpleExpression*)NULL;
                             $$ = ptr; }
          | simpleExpression OP4 simpleExpression { 
                struct Expression* ptr = malloc(sizeof(struct Expression));
                ptr->simpleExpr1 = $1;
                ptr->op4 = $2;
                ptr->simpleExpr2 = $3;
                $$ = ptr; }
          ;

simpleExpression:
                term OP3 term { struct SimpleExpression* ptr = malloc(sizeof(struct SimpleExpression));
                                ptr->term1 = $1;
                                ptr->op3 = $2;
                                ptr->term2 = $3;
                                $$ = ptr; }
                | term { struct SimpleExpression* ptr = malloc(sizeof(struct SimpleExpression));
                         ptr->term1 = $1;
                         ptr->op3 = (char*)NULL;
                         ptr->term2 = (struct Term*)NULL;
                         $$ = ptr; }
                ;

term:
    factor OP2 factor { struct Term* ptr = malloc(sizeof(struct Term));
                        ptr->factor1 = $1;
                        ptr->op2 = $2;
                        ptr->factor2 = $3;
                        $$ = ptr; }
    | factor { struct Term* ptr = malloc(sizeof(struct Term));
               ptr->factor1 = $1;
               ptr->op2 = (char*)NULL;
               ptr->factor2 = (struct Factor*)NULL;
               $$ = ptr;}
    ;

factor:
      ident { 
            SymbolTableEntry *entry = find_variable($1);
            if (!entry) {
                fprintf(stderr, "ERROR: variable '%s' not declared yet\n", $1);
                yyerror("ERROR: variable not declared yet");
                exit(EXIT_FAILURE);
            }
            struct Factor* ptr = malloc(sizeof(struct Factor));
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
    yyout = fopen("output.c", "w");
    int parseResult = yyparse();
    if (parseResult == 0) printf("---SUCCESS---\n");
    else printf("---FAILURE---\n");
    return 0;
}

void genFactor(struct Factor* factor) {
    if (factor->ident != NULL) {
        fprintf(yyout, "%s", factor->ident);
    }
    else if (factor->num != NULL) {
        fprintf(yyout, "%d", *(factor->num));
    }
    else if (factor->bool != NULL) {
        fprintf(yyout, "%s", factor->bool);
    }
    else if (factor->expr != (struct Expression*)NULL) {
        fprintf(yyout, "(");
        genExpression(factor->expr);
        fprintf(yyout, ")");
    }
}

void genTerm(struct Term* term) {
    genFactor(term->factor1);
    
    if (term->factor2 != (struct Factor*)NULL) {
        fprintf(yyout, " %s ", term->op2);
        genFactor(term->factor2);
    }
}

void genSimpleExpression(struct SimpleExpression* simpleExpression) {
    genTerm(simpleExpression->term1);
    if (simpleExpression->term2 != (struct Term*)NULL) {
        fprintf(yyout, " %s ", simpleExpression->op3);
        genTerm(simpleExpression->term2); 
    }
}

void genExpression(struct Expression* expression) {
    genSimpleExpression(expression->simpleExpr1);
    if (expression->simpleExpr2 != (struct SimpleExpression*)NULL) {
        fprintf(yyout, " %s ", expression->op4);
        genSimpleExpression(expression->simpleExpr2);
    }
}

void genWriteInt(struct WriteInt* writeInt) {
    fprintf(yyout, "printf(\"%%d\\n\", ");
    genExpression(writeInt->expr);
    fprintf(yyout, ");\n");
}

void genAssignment(struct Assignment* assignment) {
    if (assignment->expr != (struct Expression*)NULL) {
        fprintf(yyout, "%s = ", assignment->ident);
        genExpression(assignment->expr);
    }
    else {
        fprintf(yyout, "scanf(\"%%d\", &%s)", assignment->ident);
    }
    fprintf(yyout, ";\n");
}

void genIfStatement(struct IfStatement* ifStatement) {
    fprintf(yyout, "if (");
    genExpression(ifStatement->expr);
    fprintf(yyout, ") {\n");
    genStatementSeq(ifStatement->stmtSeq);
    fprintf(yyout, "}\n");
    if (ifStatement->elseClause != (struct ElseClause*)NULL) {
        genElseClause(ifStatement->elseClause);
    }
}

void genElseClause(struct ElseClause* elseClause) {
    fprintf(yyout, "else {\n");
    if (elseClause->stmtSeq != (struct StatementSequence*)NULL) {
        genStatementSeq(elseClause->stmtSeq);
    }
    fprintf(yyout, "}\n");
}

void genWhileStatement(struct WhileStatement* whileStatement) {
    fprintf(yyout, "while (");
    genExpression(whileStatement->expr);
    fprintf(yyout, ") {\n");
    genStatementSeq(whileStatement->stmtSeq);
    fprintf(yyout, "}\n");
}

void genStatement(struct Statement* statement) {
    if (statement->assignment != (struct Assignment*)NULL) {
        genAssignment(statement->assignment);
    }
    else if (statement->ifStmt != (struct IfStatement*)NULL) {
        genIfStatement(statement->ifStmt);
    }
    else if (statement->whileStmt != (struct WhileStatement*)NULL) {
        genWhileStatement(statement->whileStmt);
    }
    else if (statement->writeInt != (struct WriteInt*)NULL) {
        genWriteInt(statement->writeInt);
    }
    else {
        fprintf(stderr, "ERROR with genStatement, all properties are NULL");
    }
}

void genStatementSeq(struct StatementSequence* sequence) {
    int i = 0;
    while (sequence != (struct StatementSequence*)NULL) {
        genStatement(sequence->stmt);
        sequence = sequence->stmtSeq;
    }
}

void genType(struct Type* type) {
    fprintf(yyout, "%s", type->type);
}

void genDecls(struct Declarations* decl) {
    while (decl != (struct Declarations*)NULL) {
        fprintf(yyout, "%s ", decl->type->type);
        fprintf(yyout, "%s;\n", decl->ident);
        decl = decl->decl;
    }
    fprintf(yyout, "\n");
}

void genCode(struct Declarations* decl, struct StatementSequence* seq) {
    fprintf(yyout, "#include <stdio.h>\n");
    fprintf(yyout, "#include <stdlib.h>\n\n");
    fprintf(yyout, "int main() {\n");

    genDecls(decl);
    genStatementSeq(seq);

    fprintf(yyout, "\nreturn 0;\n}\n");
}

