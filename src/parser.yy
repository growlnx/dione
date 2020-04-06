%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.2"
%defines
%define api.parser.class {Parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%code requires {

#include <string>
#include "ast.hh"

namespace dione {
namespace driver {
class Driver;
}
}

namespace ast = dione::ast;
namespace driver = dione::driver;
}

// The parsing context.
%param { driver::Driver& driver }

%locations

%initial-action
{
  // Initialize the initial location.
  @$.begin.filename = @$.end.filename = &driver.file;
};

%define parse.trace

%define parse.error verbose

%code {

#include "driver.hh"
#include "ast.hh"

namespace ast = dione::ast;

}

%define api.token.prefix {TOK_}

// ast leafs tokens
%token DCL "dcl"
%token END 0 "end of file"
%token SWAP ">.<"
%token L_ASS ".<"
%token R_ASS ">."
%token L_PRT "("
%token R_PRT ")"
%token L_BRC "{"
%token R_BRC "}"
%token MINUS "-"
%token PLUS "+"
%token MULT "*"
%token DIV "/"
%token MOD "%"
%token COMMA ","
%token AS "as"
%token IMPORT "import"
%token EXPORT "export"
%token WHILE "while"
%token FOR "for"
%token IF "if"
%token ELSIF "elsif"
%token ELSE "else"

// ast leafs tokens with values
%token <bool> LOGIC "logic data type"
%token <std::string> TEXT "text data type"
// TODO: implement 0b0.. and 0x0.. integer tokens
// %token <int> BIN_INTEGER "binary integer data type"
// %token <int> HEX_INTEGER "hexadecimal integer data type"
%token <int> DEC_INTEGER "decimal integer data type"
%token <float> REAL "real data type"
%token <std::string> VAR_ID "identifier"
%token <std::string> FCN_ID "function identifier"
%token <std::string> DATA_ID "data type identifier"

// ast nodes
%type <ast::Dione*> dione "dione program"
%type <ast::Expression*> expr "expression"
%type <ast::Number*> number "number"
%type <ast::Object*> object "object"
%type <ast::FunctionCall*> fcn_call "function call"
//%type <ast::Assign*> assign "assignment"

%printer { yyoutput << $$; } <*>;

%start dione;

// precedence, minor first
%left MINUS PLUS
%left MULT DIV

%%

dione:
  expr 
  {
    $1->print(1);
  }
  ;

object:
  LOGIC
  {
    $$ = new ast::Object();
    $$->logic = new bool($1);   
  }
  | TEXT
  {
    // TODO
  }
  | number
  {
    $$ = new ast::Object();
    $$->number = $1;
  }
  | fcn_call
  {
    // TODO  
  }
  ;

number:
  REAL
  {
    $$ = new ast::Number();
    $$->real = new float;
    *$$->real = $1;
  } 
  | DEC_INTEGER
  {
    $$ = new ast::Number();
    $$->integer = new int;
    *$$->integer = $1;
  }
  // | BIN_INTEGER
  // {
  //   // TODO
  // }
  // | HEX_INTEGER
  // {
  //   // TODO
  // }
  ;

fcn_call:
  FCN_ID L_PRT object_list R_PRT
  {
    // TODO
  }
  ;

object_list:
  object
  | object_list COMMA object_list
  {
    // TODO
  } 
  ;

expr:
  | object
  {
    $$ = new ast::Expression();
    $$->object = $1;
  }
  | L_PRT expr R_PRT
  {
    $$ = new ast::Expression();
    $$->expr = $2;
  }
  | expr MINUS expr
  {
    $$ = new ast::Expression();
    $$->lExpr = $1;
    $$->operatorMinus = true;
    $$->rExpr = $3;
  }
  | expr PLUS expr
  {
    $$ = new ast::Expression();
    $$->lExpr = $1;
    $$->operatorPlus = true;
    $$->rExpr = $3;
  }
  | expr MULT expr
  {
    $$ = new ast::Expression();
    $$->lExpr = $1;
    $$->operatorMult = true;
    $$->rExpr = $3;
  }
  | expr DIV expr
  {
    $$ = new ast::Expression();
    $$->lExpr = $1;
    $$->operatorDiv = true;
    $$->rExpr = $3;
  }
  | expr MOD expr
  {
    $$->lExpr = $1;
    $$->operatorMod = true;
    $$->rExpr = $3;
  }
  ;

assign:
  | VAR_ID L_ASS expr
  {
    // TODO
  }
  | expr R_ASS VAR_ID
  {
    // TODO
  } 
  ;

%%

void
yy::Parser::error(const location_type& loc, const std::string& msg)
{
  driver.error(loc, msg);
}
