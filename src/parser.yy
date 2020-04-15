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
%token UNDCL "undeclare"
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

object[result]:
  LOGIC
  {
    // $result = std::make_unique<ast::Object>($1);
  }
  | TEXT[text]
  {
    $result = std::make_unique<ast::Object>($text);
  }
  | number
  {
    $result = std::make_unique<ast::Object>(std::move($number));
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

number[result]:
  REAL[real]
  {
    $result = std::make_unique<ast::Number>($real);
  }
  | DEC_INTEGER[integer]
  {
    $result = std::make_unique<ast::Number>($integer);
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

expr[result]:
  object
  {
    $result = std::make_unique<ast::Expression>(std::move($object));
  }
  | MINUS expr[expression] %prec NEG
  {
    if ($expression->object and not $expression->object->number) {
      error(@expression, "Semantic error, negative signal can only be set to numbers");
      YYABORT;
    }

    $expression->negative_signal = true;
    $expression->positive_signal = false;
    $result = std::make_unique<ast::Expression>(std::move($expression));
  }
  | PLUS expr[expression] %prec POS
  {
    if($expression->object and not $expression->object->number) {
      error(@expression, "Semantic error, positive signal can only be set to numbers or expressions");
      YYABORT;
    }

    $expression->negative_signal = false;
    $expression->positive_signal = true;
    $result = std::make_unique<ast::Expression>(std::move($expression));
  }
  | L_PRT expr[expression] R_PRT
  {
    $result = std::make_unique<ast::Expression>(std::move($expression));
  }
  | expr[leftExpression] MINUS[operator] expr[rightExpression]
  {
    $result = std::make_unique<ast::Expression>(
      std::move($leftExpression),
      std::move($operator), 
      std::move($rightExpression)
    );
  }
  | expr[leftExpression] PLUS[operator] expr[rightExpression]
  {
    $result = std::make_unique<ast::Expression>(
      std::move($leftExpression), 
      std::move($operator), 
      std::move($rightExpression)
    );
  }
  | expr[leftExpression] MULT[operator] expr[rightExpression]
  {
    $result = std::make_unique<ast::Expression>(
      std::move($leftExpression), std::move($operator), std::move($rightExpression));
  }
  | expr[leftExpression] DIV[operator] expr[rightExpression]
  {
    if ($rightExpression->object and $rightExpression->object->number and (($rightExpression->object->number->real 
        and *$rightExpression->object->number->real == 0) or ($rightExpression->object->number->integer 
        and *$rightExpression->object->number->integer == 0))) {
      error(@operator, "Semantic error, division by zero is not allowed");
      YYABORT;
    }

    $result = std::make_unique<ast::Expression>(
      std::move($leftExpression), std::move($operator), std::move($rightExpression));
  }
  | expr[leftExpression] MOD[operator] expr[rightExpression]
  {
    // mod é uma operação matemática definida para números inteiros.
    if (not($leftExpression->object and $leftExpression->object->number and $rightExpression->object 
      and $rightExpression->object->number)) {
      error(@operator, "Semantic error, mod operation can be done only with numbers");
      YYABORT;
    }

    if ($leftExpression->object->number->real) {
      // TODO: emitir nota informando o casting forçado
      $leftExpression->object->number->integer =
        std::make_unique<int>((int)*$leftExpression->object->number->real);
    }

    if ($rightExpression->object->number->real) {
      // TODO: emitir nota informando o casting forçado
      $rightExpression->object->number->integer =
        std::make_unique<int>((int)*$rightExpression->object->number->real);
    }

    if (*$rightExpression->object->number->integer == 0) {
      error(@operator, "Semantic error, module by zero is not allowed");
      YYABORT;
    }

    $result = std::make_unique<ast::Expression>(
      std::move($leftExpression), std::move($operator), std::move($rightExpression));
  }
  ;

assign:
  | VAR_ID L_ASS expr
  {
    // TODO: implementar análise semântica
  }
  | expr R_ASS VAR_ID
  {
    // TODO: implementar análise semântica
  }
  ;

%%

void
yy::Parser::error(const location_type& loc, const std::string& msg)
{
  driver.error(loc, msg);
}
