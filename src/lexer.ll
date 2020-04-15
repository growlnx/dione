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
#define YY_USER_ACTION  loc.columns (yyleng);
%}

%x MULT_COMMENT

%%

%{

// Code run each time yylex is called.
loc.step();

%}

<INITIAL>"|-"  {
                  BEGIN(MULT_COMMENT);
                  loc.step();
                }

<INITIAL>"--".* {
                  loc.step();
                }

<INITIAL>{blank}+ {
                    loc.step();
                  }

<INITIAL>[\n]+  {
                  loc.lines(yyleng); 
                  loc.step();
                }

<INITIAL>"-"  {
                return yy::Parser::make_MINUS(ast::op_type::MINUS, loc);
              }

<INITIAL>"+"  {
                return yy::Parser::make_PLUS(ast::op_type::PLUS, loc);
              }

<INITIAL>"*"  {
                return yy::Parser::make_MULT(ast::op_type::MULT, loc);
              }

<INITIAL>"/"  {
                return yy::Parser::make_DIV(ast::op_type::DIV, loc);
              }

<INITIAL>"%"  {
                return yy::Parser::make_MOD(ast::op_type::MOD, loc);
              }

<INITIAL>"("  {
                return yy::Parser::make_L_PRT(loc);
              }

<INITIAL>")"  {
                return yy::Parser::make_R_PRT(loc);
              }

<INITIAL>"{"  {
                return yy::Parser::make_L_BRC(loc);
              }

<INITIAL>"}"  {
                return yy::Parser::make_R_BRC(loc);
              }

<INITIAL>"<<" {
                return yy::Parser::make_L_ASS(loc);
              }

<INITIAL>">>" {
                return yy::Parser::make_R_ASS(loc);
              }

<INITIAL>"><" {
                return yy::Parser::make_SWAP(loc);
              }

<INITIAL>"pure" {
                  return yy::Parser::make_PURE(loc);
                }

<INITIAL>"declare"  {
                      return yy::Parser::make_DCL(loc);
                    }

<INITIAL>"true" {
                  return yy::Parser::make_LOGIC(true, loc);
                }

<INITIAL>"false"  {
                    return yy::Parser::make_LOGIC(false, loc);
                  }

<INITIAL>"as" {
                return yy::Parser::make_AS(loc);
              }

<INITIAL>"import" {
                    return yy::Parser::make_IMPORT(loc);
                  }

<INITIAL>"export" {
                    return yy::Parser::make_EXPORT(loc);
                  }

<INITIAL>"while"  {
                    return yy::Parser::make_WHILE(loc);
                  }

<INITIAL>"for"  {
                  return yy::Parser::make_FOR(loc);
                }

<INITIAL>"if" {
                return yy::Parser::make_IF(loc);
              }

<INITIAL>"elsif"  {
                    return yy::Parser::make_ELSIF(loc);
                  }

<INITIAL>"else" {
                  return yy::Parser::make_ELSE(loc);
                }

<INITIAL>{int}  {
                  errno = 0;
                  long n = strtol (yytext, NULL, 10);
            
                  if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
                    driver.error (loc, "integer is out of range");
            
                  return yy::Parser::make_DEC_INTEGER(n, loc);
                }

<INITIAL>{int}\.{int} {
                        errno = 0;
                        double n = strtod(yytext, NULL);
                        // TODO: error handling here
                        return yy::Parser::make_REAL(n, loc);
                      }

<INITIAL>[a-z]{id}  { 
                      return yy::Parser::make_VAR_ID(yytext, loc);
                    }

<INITIAL>[A-Z]{id}  {
                      return yy::Parser::make_FCN_ID(yytext, loc);
                    }

<INITIAL>\"(\\.|[^"\\])*\"  {
                              // TODO: avaliar se é melhor fazer este escaneamento usando outro estado 
                              std::string str(yytext);
                              return yy::Parser::make_TEXT(str.substr(1,str.size()-2), loc);
                            }

<INITIAL>~{id}  {
                  return yy::Parser::make_DATA_ID(yytext, loc);
                }

<INITIAL>.  {
              // driver.error (loc, "invalid token: "+std::string(yytext));
              std::cerr << "[DIONE]:" << loc << ": Lexical error, invalid token: "+std::string(yytext) << std::endl;
              std::exit(1);
            }

<INITIAL><<EOF>>  {
                    return yy::Parser::make_END(loc);
                  }

<MULT_COMMENT>"-|"  {
                      // aqui termina o comentário multline
                      loc.step();
                      BEGIN(INITIAL);
                    }

<MULT_COMMENT>. {
                  loc.step();
                }

<MULT_COMMENT><<EOF>> {
                        std::cerr << "[DIONE]" << loc << ": Lexical error, unclosed multline comment, expected a -|" << std::endl;
                        std::exit(1);
                      }

%%
