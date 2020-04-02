%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "driver.hh"
# include "parser.hh"

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

id    [a-zA-Z][a-zA-Z_0-9]*

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

"-"       {
            return yy::Parser::make_MINUS(loc);
          }

"+"       {
            return yy::Parser::make_PLUS(loc);
          }

"*"       {
            return yy::Parser::make_STAR(loc);
          }

"/"       {
            return yy::Parser::make_SLASH(loc);
          }

"("       {
            return yy::Parser::make_LPAREN(loc);
          }

")"       {
            return yy::Parser::make_RPAREN(loc);
          }

":="      {
            return yy::Parser::make_ASSIGN(loc);
          }


{int}     {
            errno = 0;
            long n = strtol (yytext, NULL, 10);
            
            if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
              driver.error (loc, "integer is out of range");
            
            return yy::Parser::make_NUMBER(n, loc);
          }

{id}      { 
            return yy::Parser::make_IDENTIFIER(yytext, loc);
          }

.         {
            driver.error (loc, "invalid token: "+std::string(yytext));
          }

<<EOF>>   { 
            return yy::Parser::make_END(loc);
          }
%%

void
Driver::scan_begin() 
{
  yy_flex_debug = trace_scanning;

  if (file.empty () || file == "stdin") {
    yyin = stdin;
  
  } else if (!(yyin = fopen (file.c_str (), "r"))) {
    error("cannot open " + file + ": " + strerror(errno));
    exit(EXIT_FAILURE);
  }

}

void
Driver::scan_end()
{
  fclose(yyin);
}