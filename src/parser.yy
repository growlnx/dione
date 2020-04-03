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

class Driver;

namespace ast = oberon::ast;

}

// The parsing context.
%param { Driver& driver }

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
//#include "ast.hh"

//namespace ast = oberon::ast;

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
%token EXTERN "extern"
%token NAMESPACE "namespace"
%token NAMESPACE_SEP "->"

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
%type <ast::Oberon*> oberon "oberon"
%type <ast::Block*> namespaceBlock "block"
%type <ast::Expression*> expr "expression"
%type <ast::Number*> number "number"
%type <ast::Object*> object "object"
%type <ast::FunctionCall*> fcn_call "function call"
%type <ast::Assign*> assign "assignment"
%type <ast::CmdList*> namespaceCmdList "Command List"
%type <ast::Namespace*> namespace;

%printer { yyoutput << $$; } <*>;

%start oberon;

%%

oberon: 
  namespace 
  { 
    // TODO: store ast in driver 
  }
  ;

namespace:
  NAMESPACE namespaceId namespaceBlock
  {
    
  }
  ;

namespaceId:
  VAR_ID
  {

  }
  | namespaceId NAMESPACE_SEP namespaceId
  {

  }
  ;

namespaceBlock:
  L_BRC namespaceCmdList R_BRC
  {
    // TODO
  }
  ;

namespaceCmdList: 
  | namespace
  | varDef namespaceCmdList
  {
    // TODO
  }
  | fcnDef namespaceCmdList
  {
    // TODO
  }
  ;

varDef:
  DCL VAR_ID AS DATA_ID
  {
    // TODO
  }
  | DCL VAR_ID AS DATA_ID L_ASS EXTERN
  {
    // TODO
  }
  | DCL VAR_ID AS DATA_ID L_ASS expr
  {
    // TODO
  }
  ;

fcnDef:
  DCL FCN_ID AS DATA_ID L_ASS
  {
    // TODO
  }
  ;


object:
  LOGIC
  {
    // TODO
       
  }
  | TEXT
  {
    // TODO
  
  }
  | number
  {
    // TODO
  
  }
  | fcn_call
  {
    // TODO
  
  }
  ;

number:
  REAL
  {
    // TODO
  } 
  | DEC_INTEGER
  {
    // TODO
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
    // TODO
  }
  | L_PRT expr R_PRT
  {
    // TODO
  }
  | expr op expr
  {
    // TODO
  }
  ;

op: 
  MINUS 
  {
    // TODO
  }
  | PLUS 
  {
    // TODO
  }
  | MULT 
  {
    // TODO
  }
  | DIV 
  {
    // TODO
  }
  | MOD
  {
    // TODO
  }
  | SWAP
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
