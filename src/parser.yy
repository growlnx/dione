%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.2"

%defines
%define api.parser.class {Parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires {

#include <string>
#include <iostream>
#include "ast.hh"

#define YYDEBUG 1

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

%token DCL "declare"
%token END 0 "end of file"
%token SWAP "><"
%token L_ASS "<<"
%token R_ASS ">>"
%token L_PRT "("
%token R_PRT ")"
%token L_BRC "{"
%token R_BRC "}"
%token COMMA ","
%token AS "as"
%token IMPORT "import"
%token EXPORT "export"
%token WHILE "while"
%token FOR "for"
%token IF "if"
%token ELSIF "elsif"
%token ELSE "else"
%token PURE "pure"

%token <ast::op_type> MINUS "-"
%token <ast::op_type> PLUS "+"
%token <ast::op_type> MULT  "*"
%token <ast::op_type> DIV "/"
%token <ast::op_type> MOD "%"

%token <bool> LOGIC "logic data type"
%token <std::string> TEXT "text data type"
// TODO: implementar 0b0.. and 0x0.. integer tokens
// %token <int> BIN_INTEGER "binary integer data type"
// %token <int> HEX_INTEGER "hexadecimal integer data type"
%token <int> DEC_INTEGER "decimal integer data type"
%token <float> REAL "real data type"
%token <std::string> VAR_ID "identifier"
%token <std::string> FCN_ID "function identifier"
%token <std::string> DATA_ID "data type identifier"

// ast nodes
%type <std::unique_ptr<ast::Dione>> dione "dione program"
%type <std::unique_ptr<ast::Expression>> expr "expression"
%type <std::unique_ptr<ast::Number>> number "number"
%type <std::unique_ptr<ast::Object>> object "object"
%type <std::unique_ptr<ast::FunctionCall>> fcn_call "function call"
//%type <ast::Assign*> assign "assignment"

%start dione;

// precedence, minor first
%left MINUS PLUS
%left MULT DIV
%precedence NEG POS

%%

dione:
  expr
  {
    $1->print(0);
  }
  ;

object:
  LOGIC
  {
    *$$->logic = $1;
  }
  | TEXT
  {
    $$ = std::make_unique<ast::Object>($1);
  }
  | number
  {
    $$ = std::make_unique<ast::Object>(std::move($1));
  }
  | fcn_call
  {
    // TODO
  }
  ;

number:
  REAL
  {
    $$ = std::make_unique<ast::Number>($1);
  }
  | DEC_INTEGER
  {
    $$ = std::make_unique<ast::Number>($1);
  }
  //| BIN_INTEGER
  //{
  //  // TODO
  //}
  //| HEX_INTEGER
  //{
  //  // TODO
  //}
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
  object
  {
    $$ = std::make_unique<ast::Expression>(std::move($1));
  }
  | L_PRT expr R_PRT
  {
    $$ = std::make_unique<ast::Expression>(std::move($2));
  }
  | expr MINUS expr
  {
    $$ = std::make_unique<ast::Expression>(std::move($1), std::move($2), std::move($3));

  }
  | expr PLUS expr
  {
    $$ = std::make_unique<ast::Expression>(std::move($1), std::move($2), std::move($3));
  }
  | expr MULT expr
  {
    $$ = std::make_unique<ast::Expression>(std::move($1), std::move($2), std::move($3));
  }
  | expr DIV expr
  {
    // TODO:
    // - verificar se operando é nulo
    $$ = std::make_unique<ast::Expression>(std::move($1), std::move($2), std::move($3));
  }
  | expr MOD expr
  { 
    // mod é uma operação matemática definida para números inteiros.   
    if(not ($1->object and $1->object->number and $3->object and $3->object->number)) {
      error(@2, "Semantic error, mod operation can be done only with numbers");
      YYABORT;
    } 

    if($1->object->number->real) {
      // TODO: emitir nota informando o casting forçado
      $1->object->number->integer = std::make_unique<int>((int) *$1->object->number->real);
    }

    if($3->object->number->real) {
      // TODO: emitir nota informando o casting forçado
      $3->object->number->integer = std::make_unique<int>((int) *$3->object->number->real);
    }

    $$ = std::make_unique<ast::Expression>(std::move($1), std::move($2), std::move($3));
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
