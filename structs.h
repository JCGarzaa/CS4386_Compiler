
struct Program {
    struct Declarations* decl;
    struct StatementSequence* stmtSeq;
};

struct Declarations {
    char* ident;
    struct Type* type;
    struct Declarations* decl;
};

struct Type {
    char* type;
};

struct StatementSequence {
    struct Statement* stmt;
    struct StatementSequence* stmtSeq;
};

struct Statement {
    struct Assignment* assignment;
    struct IfStatement* ifStmt;
    struct WhileStatement* whileStmt;
    struct WriteInt* writeInt;
};

struct Assignment {
    char* ident;
    struct Expression* expr;
};

struct IfStatement {
    struct Expression* expr;
    struct StatementSequence* stmtSeq;
    struct ElseClause* elseClause;
};


struct ElseClause {
    struct StatementSequence* stmtSeq;
};

struct WhileStatement {
    struct Expression* expr;
    struct StatementSequence* stmtSeq;
};

struct WriteInt {
    struct Expression* expr;
};

struct Expression {
    struct SimpleExpression* simpleExpr1;
    // char* op4; // NOTE: maybe remove this
    struct SimpleExpression* simpleExpr2;
};

struct SimpleExpression {
    struct Term* term1;
    // char* op3; // NOTE: maybe remove this
    struct Term* term2;
};

struct Term {
    struct Factor* factor1;
    // char* op2; // NOTE: maybe remove this
    struct Factor* factor2;
};

struct Factor {
    char* ident;
    long num;
    char* bool;
    struct Expression* expr;
};

