%skeleton "lalr1.cc" /* -*- C++ -*- */

%require "3.2"

%defines

%define api.parser.class {Parser}

%define api.token.constructor

%define api.value.type variant

%define parse.assert

%code requires {

#include <string>
class Driver;

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
}

%define api.token.prefix {TOK_}

%token
  END  0  "end of file"
  ASSIGN  ":="
  MINUS   "-"
  PLUS    "+"
  STAR    "*"
  SLASH   "/"
  MOD     "%"
  LPAREN  "("
  RPAREN  ")"
;

%token <std::string> IDENTIFIER "identifier"
%token <int> NUMBER "number"
%type  <int> exp "expression"

%printer { yyoutput << $$; } <*>;

%start program;

%%

program:
  NUMBER PLUS NUMBER
  { 
    // driver.result = $2; 
  }
  | error 
  {
    // std::cout << "ERROOU" << std::endl;
    error(@1, "errou\n");
    exit(0);
  }
  ;

%%

void
yy::Parser::error (const location_type& l, const std::string& m)
{
  driver.error (l, m);
}
