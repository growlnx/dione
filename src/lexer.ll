%{ 
/* -*- C++ -*- */
#include <climits>
#include <cstdlib>
#include <string>
#include "driver.hh"
#include "parser.hh"

// Work around an incompatibility in flex (at least versions
// 2.5.31 through 2.5.33): it generates code that does
// not conform to C89.  See Debian bug 333231
// <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=333231>.
# undef yywrap
# define yywrap() 1

// The location of the current token.
static yy::location loc;
%}

%option noyywrap nounput batch debug noinput

id    [a-zA-Z~0-9]*

int   [0-9]+

blank [ \t]

%{
// Code run each time a pattern is matched.
# define YY_USER_ACTION  loc.columns (yyleng);
%}

%%

%{
// Code run each time yylex is called.
loc.step ();
%}

{blank}+  {
            loc.step ();
          }

[\n]+     {
            loc.lines (yyleng); 
            loc.step ();
          }

"--".*    {
            // ignore comments
            loc.step();
          }

"-"       {
            return yy::Parser::make_MINUS(loc);
          }

"+"       {
            return yy::Parser::make_PLUS(loc);
          }

"*"       {
            return yy::Parser::make_MULT(loc);
          }

"/"       {
            return yy::Parser::make_DIV(loc);
          }

"%"       {
            return yy::Parser::make_MOD(loc);
          }

"("       {
            return yy::Parser::make_L_PRT(loc);
          }

")"       {
            return yy::Parser::make_R_PRT(loc);
          }

"{"       {
            return yy::Parser::make_L_BRC(loc);
          }

"}"       {
            return yy::Parser::make_R_BRC(loc);
          }

".<"      {
            return yy::Parser::make_L_ASS(loc);
          }

">."      {
            return yy::Parser::make_R_ASS(loc);
          }

">.<"     {
            return yy::Parser::make_SWAP(loc);
          }

"pure"    {
            return yy::Parser::make_PURE(loc);
          }

"declare" {
            return yy::Parser::make_DCL(loc);
          }

"true"    {
            return yy::Parser::make_LOGIC(true, loc);
          }

"false"   {
            return yy::Parser::make_LOGIC(false, loc);
          }

"as"      {
            return yy::Parser::make_AS(loc);
          }

"import"  {
            return yy::Parser::make_IMPORT(loc);
          }

"export"  {
            return yy::Parser::make_EXPORT(loc);
          }

"while"   {
            return yy::Parser::make_WHILE(loc);
          }

"for"     {
            return yy::Parser::make_FOR(loc);
          }

"if"      {
            return yy::Parser::make_IF(loc);
          }

"elsif"   {
            return yy::Parser::make_ELSIF(loc);
          }

"else"    {
            return yy::Parser::make_ELSE(loc);
          }

{int}     {
            errno = 0;
            long n = strtol (yytext, NULL, 10);
            
            if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
              driver.error (loc, "integer is out of range");
            
            return yy::Parser::make_DEC_INTEGER(n, loc);
          }

{int}\.{int} {
               errno = 0;
               double n = strtod(yytext, NULL);
               // TODO: error handling here
               return yy::Parser::make_REAL(n, loc);
             }

[a-z]{id} { 
            return yy::Parser::make_VAR_ID(yytext, loc);
          }

[A-Z]{id} {
            return yy::Parser::make_FCN_ID(yytext, loc);
          }

~{id}     {
            return yy::Parser::make_DATA_ID(yytext, loc);
          }

.         {
            // driver.error (loc, "invalid token: "+std::string(yytext));
            std::cerr << "[DIONE]:" << loc << ": Lexical error, invalid token: "+std::string(yytext) << std::endl;
            std::exit(1);
          }

<<EOF>>   { 
            return yy::Parser::make_END(loc);
          }
%%
