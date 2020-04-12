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
%token PURE "pure"

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
    // TODO
  }
  | number
  {
    $$ = std::make_unique<ast::Object>();
    $$->number =std::move($1);
  }
  | fcn_call
  {
    // TODO
  }
  ;

number:
  REAL
  {
     $$ = std::make_unique<ast::Number>();
    *$$->real = $1;
  }
  | DEC_INTEGER
  {
    $$ = std::make_unique<ast::Number>();
    $$->integer = std::make_unique<int>();
    *$$->integer = $1;
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
    $$ = std::make_unique<ast::Expression>();
    $$->object = std::move($1);
  }
  | L_PRT expr R_PRT
  {
    $$ = std::make_unique<ast::Expression>();

    if($2->object) {

      #if YYDEBUG
        std::cout << "Dione:" << @2 << ": (object) -> object" << std::endl;
      #endif

      $$->object = std::move($2->object);

    } else if ($2->expr) {
      
      #if YYDEBUG
        std::cout << "Dione:" << @2 <<  ": ((expr)) -> (expr)" << std::endl;
      #endif

      $$->expr = std::move($2->expr);
    
    } else {
      $$->expr = std::move($2);
    }
  }
  | expr MINUS expr
  {
    // TODO
  }
  | expr PLUS expr
  {
    // TODO
  }
  | expr MULT expr
  {
    // TODO
  }
  | expr DIV expr
  {
    // TODO
  }
  | expr MOD expr
  {
    // TODO    
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
