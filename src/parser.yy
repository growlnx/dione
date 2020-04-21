%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.2"

%defines
%define api.parser.class {Parser}
%define api.token.prefix {TOKEN_}
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define parse.trace
%define parse.error verbose

%code requires {

#include <string>
#include <iostream>
#include "ast.hh"

namespace dione {
namespace driver {
class Driver;
} // namespace driver
} // namespace dione

namespace ast = dione::ast;
namespace driver = dione::driver;
}

// The parsing context.
%param {driver::Driver& driver}

%locations

%initial-action
{
  // Initialize the initial location.
  @$.begin.filename = @$.end.filename = &driver.file;
};

%code {
#include "driver.hh"

namespace ast = dione::ast;

#define OPTIMIZE(NODE) if(driver.optimize) NODE->optimize()

#define BIN_EXPR(NODE, OP, OP_LOC, L_NODE, L_NODE_LOC, R_NODE, R_NODE_LOC) {  \
  NODE = new ast::Expression;                                                 \
  NODE->op = OP;                                                              \
  NODE->op_loc = OP_LOC;                                                      \
  NODE->left_expression = L_NODE;                                             \
  NODE->left_expression_loc = L_NODE_LOC;                                     \
  NODE->right_expression = R_NODE;                                            \
  NODE->right_expression_loc = R_NODE_LOC;                                    \
}

}

// delimitadores
%token                END 0     "end of file"
%token                L_PRT     "("
%token                R_PRT     ")"
%token                L_BCK     "["
%token                R_BCK     "]"
%token                L_BRC     "{"
%token                R_BRC     "}"
%token                COMMA     ","
%token                DOT       "."

// palavras reservadas - keywords
%token                DCL       "declare"
%token                AS        "as" 
%token                IMPORT    "import" 
%token                EXPORT    "export" 
%token                WHILE     "while" 
%token                FOR       "for"
%token                IF        "if"
%token                ELSIF     "elsif"
%token                ELSE      "else"
%token                PURE      "pure"

// type names
%token                T_LOGIC   "logic"
%token                T_TEXT    "text"
%token                T_CHAR     "char"
%token                T_INTEGER "integer"
%token                T_REAL    "real"

// operadores
%token <ast::op_type> MINUS     "-"
%token <ast::op_type> PLUS      "+"
%token <ast::op_type> MULT      "*"
%token <ast::op_type> DIV       "/"
%token <ast::op_type> MOD       "%"
%token <ast::op_type> AND       "and"
%token <ast::op_type> OR        "or"
%token <ast::op_type> NOT       "not"
%token <ast::op_type> EQ        "=="
%token <ast::op_type> MAJ        ">"
%token <ast::op_type> MIN       "<"
%token <ast::op_type> N_EQ      "!="
%token <ast::op_type> MAJEQ     ">="
%token <ast::op_type> MINEQ     "<="
%token <ast::op_type> SWAP      "><"
%token <ast::op_type> L_ASS     "<<"
%token <ast::op_type> R_ASS     ">>"

// literais
%token <bool>         LOGIC       "logic literal" 
%token <std::string>  TEXT        "text literal"
%token <int>          INTEGER     "integer literal"
%token <float>        REAL        "real literal"
%token <std::string>  IDENTIFIER  "identifier"

// precedência, aumenta conforme as linhas
%left L_ASS R_ASS
%left NOT AND OR EQ NEQ MAJ MIN MINEQ MAJEQ
%left PLUS MINUS
%left MULT DIV MOD
%nonassoc AS
%precedence POS NEG

// ast nodes
%type <ast::Dione*>       dione     "dione program"
%type <ast::Expression*>  expr      "expression"
%type <ast::Object*>      object    "object"

%start dione;

%%

dione
  : expr
  {
    if($1) std::cout << $1->print(0) << std::endl;
    // $$->generateCode();
  }
  | declare_var
  {

  }
  ;

object
  : LOGIC
  {
    $$ = new ast::Object;
    $$->logic = new bool($1);
    $$->loc = @1;
  }
  | TEXT
  {
    $$ = new ast::Object;
    $$->text = new std::string($1);
    $$->loc = @1;
  }
  | REAL
  {
    $$ = new ast::Object;
    $$->real = new float($1);
    $$->loc = @1;
    OPTIMIZE($$);
  }
  | INTEGER
  {
    $$ = new ast::Object;
    $$->integer = new int($1);
    $$->loc = @1;
    OPTIMIZE($$);
  }
  | IDENTIFIER
  {
    $$->identifier = new std::string($1);
    $$->loc = @1;
    OPTIMIZE($$);
  }
  ;

expr
  : object
  {
    $$ = new ast::Expression;
    $$->object = $1;
    $$->object_loc = @1;

    OPTIMIZE($$);
  }
  | MINUS expr %prec NEG
  {
    $$ = new ast::Expression;

    if($2->object and not $2->object->isNumber()) {
      error(@1, "Semantic error, invalid negative operator with NaN object");
      YYABORT;
    }

    // se for um número a gente já resolve aqui
    if($2->object->integer) *$2->object->integer *= -1;
    else if($2->object->real) *$2->object->real *= -1;
    else $2->negative_signal = not $2->negative_signal;

    $$ = $2;
  }
  | PLUS expr %prec POS
  {
    // colocar vários ++++ não fará diferença na AST
    $$ = $2;
  }
  | NOT expr
  {
    $$ = new ast::Expression;
    $$->op = $1;
    $$->op_loc = @1;
    $$->right_expression = $2;
    $$->right_expression_loc = @2;

    OPTIMIZE($$);
  }
  | expr AS T_REAL
  {
    // TODO: casting
    if($1->object and $1->object->isNumber() and $1->object->integer) {
      $1->object->real = new float((float)*$1->object->real);
      delete $1->object->integer;
    }

    $$ = $1;
  }
  | expr AS T_INTEGER
  {
    // TODO: casting
    if($1->object and $1->object->isNumber() and $1->object->real) {
      $1->object->integer = new int((int)*$1->object->real);
      delete $1->object->real;
    }

    $$ = $1;
  }
  | L_PRT expr R_PRT
  {
    $$ = new ast::Expression;
    $$->parentheses_expression = $2;

    OPTIMIZE($$);
  }
  | expr PLUS expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr MINUS expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr MULT expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr DIV expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr MOD expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr AND expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr OR expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr EQ expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr MAJ expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr MIN expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr MAJEQ expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  | expr MINEQ expr
  {
    BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
    OPTIMIZE($$);
  }
  ;

// assigment
//   : IDENTIFIER SWAP IDENTIFIER
//   {
//     OPTIMIZE($$);
//   }
//   | IDENTIFIER L_ASS expr
//   {
//     BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
//     OPTIMIZE($$);
//   }
//   | identifier R_ASS IDENTIFIER
//   {
//     BIN_EXPR($$, $2, @2, $1, @1, $3, @3);
//     OPTIMIZE($$);
//   }
//   ;

declare_var
  : DCL var_list
  {
    // if(driver.varExists($2)) {
    //   error(@2, "Semantic error, variable or constant already declared");
    //   YYABORT;
    // }

    // driver.vars[$2] = nullptr;
  }
  ;

var_type
  : IDENTIFIER
  | IDENTIFIER AS type
  ;

var_list
  : var_type
  | var_list COMMA var_type
  ;

type
  : T_INTEGER
  | T_REAL
  | T_TEXT
  | T_LOGIC
  | T_CHAR
  ;

%%

void
yy::Parser::error(const location_type& loc, const std::string& msg)
{
  driver.error(loc, msg);
}
