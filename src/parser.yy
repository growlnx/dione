%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.2"

%defines
%define api.parser.class {Parser}
%define api.token.prefix {TOK_}
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define parse.trace
%define parse.error verbose

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

%code {
#include "driver.hh"
#include "ast.hh"

namespace ast = dione::ast;
}

// delimitadores
%token                END 0 "end of file"
%token                L_PRT     "("
%token                R_PRT     ")"
%token                L_BRC     "{"
%token                R_BRC     "}"
%token                COMMA     ","
%token                DOT       "."
// palavras reservadas - keywords
%token                DCL "declare"
%token                AS        "as" 
%token                IMPORT    "import" 
%token                EXPORT    "export" 
%token                WHILE     "while" 
%token                FOR       "for"
%token                IF        "if"
%token                ELSIF     "elsif"
%token                ELSE      "else"
%token                PURE      "pure"
// operadores
%token <ast::op_type> SWAP      "><"
%token <ast::op_type> L_ASS     "<<"
%token <ast::op_type> R_ASS     ">>"
%token <ast::op_type> MINUS     "-"
%token <ast::op_type> PLUS      "+"
%token <ast::op_type> MULT      "*"
%token <ast::op_type> DIV       "/"
%token <ast::op_type> MOD       "%"
// literais
%token <bool>         LOGIC     "logic literal"
%token <std::string>  TEXT      "text literal"
%token <int>          INTEGER   "integer literal"
%token <float>        REAL      "real literal"
%token <std::string>  VAR_ID    "identifier"
%token <std::string>  FCN_ID    "function literal"
%token <std::string>  DATA_ID   "data type literal"
// ast nodes
%type <std::unique_ptr<ast::Dione>> dione "dione program"
%type <std::unique_ptr<ast::Expression>> expr "expression"
%type <std::unique_ptr<ast::Number>> number "number"
%type <std::unique_ptr<ast::Object>> object "object"
%type <std::unique_ptr<ast::FunctionCall>> fcn_call "function call"
//%type <ast::Assign*> assign "assignment"

%start dione;

// precedência, aumenta conforme as linhas
%left PLUS MINUS
%left MULT DIV
%precedence POS NEG

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
    // $$ = std::make_unique<ast::Object>($1);
  }
  | TEXT
  {
    $$ = std::make_unique<ast::Object>($1);
  }
  | number
  {
    $$ = std::make_unique<ast::Object>(std::move($1));
  }
  | VAR_ID
  {
    // TODO: implementar análise semântica
  }
  | fcn_call
  {
    // TODO: implementar análise semântica
  }
  ;

number:
  REAL
  {
    $$ = std::make_unique<ast::Number>($1);
  }
  | INTEGER
  {
    $$ = std::make_unique<ast::Number>($1);
  }
  //| BIN_INTEGER
  //{
  //  // TODO: implementar regra na sintaxe
  //}
  //| HEX_INTEGER
  //{
  //  // TODO: implementar regra na sintaxe
  //}
  ;

fcn_call:
  FCN_ID L_PRT object_list R_PRT
  {
    // TODO: implementar regra na sintaxe
  }
  ;

object_list:
  object
  | object_list COMMA object_list
  {
    // TODO: implementar regra na sintaxe
  }
  ;

expr:
  object
  {
    $$ = std::make_unique<ast::Expression>(std::move($1));
  }
  | MINUS expr %prec NEG
  {
    if ($2->object and not $2->object->number) {
      error(@2, "Semantic error, negative signal can only be set to numbers");
      YYABORT;
    }

    $2->negative_signal = true;
    $2->positive_signal = false;
    $$ = std::make_unique<ast::Expression>(std::move($2));
  }
  | PLUS expr %prec POS
  {
    if($2->object and not $2->object->number) {
      error(@2, "Semantic error, positive signal can only be set to numbers or expressions");
      YYABORT;
    }

    $2->negative_signal = false;
    $2->positive_signal = true;
    $$ = std::make_unique<ast::Expression>(std::move($2));
  }
  | L_PRT expr R_PRT
  {
    $$ = std::make_unique<ast::Expression>(std::move($2));
  }
  | expr MINUS expr
  {
    $$ = std::make_unique<ast::Expression>(
      std::move($1),
      std::move($2), 
      std::move($3)
    );
  }
  | expr PLUS expr
  {
    $$ = std::make_unique<ast::Expression>(
      std::move($1), 
      std::move($2), 
      std::move($3)
    );
  }
  | expr MULT expr
  {
    $$ = std::make_unique<ast::Expression>(
      std::move($1), std::move($2), std::move($3));
  }
  | expr DIV expr
  {
    
    $$ = std::make_unique<ast::Expression>(
      std::move($1), std::move($2), std::move($3));
  }
  | expr MOD expr
  {
    // mod é uma operação matemática definida para números inteiros.
    if (not($1->object and $1->object->number and $3->object 
      and $3->object->number)) {
      error(@2, "Semantic error, mod operation can be done only with numbers");
      YYABORT;
    }

    if ($1->object->number->real) {
      // TODO: emitir nota informando o casting forçado
      $1->object->number->integer =
        std::make_unique<int>((int)*$1->object->number->real);
    }

    if ($3->object->number->real) {
      // TODO: emitir nota informando o casting forçado
      $3->object->number->integer =
        std::make_unique<int>((int)*$3->object->number->real);
    }

    if (*$3->object->number->integer == 0) {
      error(@2, "Semantic error, module by zero is not allowed");
      YYABORT;
    }

    $$ = std::make_unique<ast::Expression>(
      std::move($1), std::move($2), std::move($3));
  }
  ;

%%

void
yy::Parser::error(const location_type& loc, const std::string& msg)
{
  driver.error(loc, msg);
}
