%{ // -*- C++ -*- 
#include <climits>
#include <cstdlib>
#include <string>
#include "driver.hh"
#include "parser.hh"

// TODO: verificar se este abaixo foi resolvido
// Work around an incompatibility in flex (at least versions
// 2.5.31 through 2.5.33): it generates code that does
// not conform to C89.  See Debian bug 333231
// <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=333231>.
#undef yywrap
#define yywrap() 1

// The location of the current token.
static yy::location loc;
%}

%option noyywrap nounput batch debug noinput

int   [0-9]+

blank [ \t]

%{
// Code run each time a pattern is matched.
#define YY_USER_ACTION loc.columns (yyleng);
%}

%x MULT_COMMENT

%%

%{

// Code run each time yylex is called.
loc.step();

%}

<INITIAL>"-."  {
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

<INITIAL>"@"  {
                return yy::Parser::make_B_AND(ast::op_type::REF, loc);
              }

<INITIAL>"^"  {
                return yy::Parser::make_B_AND(ast::op_type::PRT, loc);
              }

<INITIAL>"&"  {
                return yy::Parser::make_B_AND(ast::op_type::PLUS, loc);
              }

<INITIAL>"|"  {
                return yy::Parser::make_B_OR(ast::op_type::PLUS, loc);
              }

<INITIAL>"~"  {
                return yy::Parser::make_B_NOT(ast::op_type::PLUS, loc);
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

<INITIAL>"."  {
                return yy::Parser::make_DOT(loc);
              }

<INITIAL>","  {
                return yy::Parser::make_COMMA(loc);
              }

<INITIAL>";"  {
                return yy::Parser::make_SEMIC(loc);
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

<INITIAL>"["  {
                return yy::Parser::make_L_BCK(loc);
              }

<INITIAL>"]"  {
                return yy::Parser::make_R_BCK(loc);
              }

<INITIAL>"->" {
                return yy::Parser::make_ARROW(loc);
              }

<INITIAL>"="  {
                return yy::Parser::make_ASSIGN(ast::op_type::ASSIGN, loc);
              }

<INITIAL>"||" {
                return yy::Parser::make_OR(ast::op_type::OR, loc);
              }

<INITIAL>"&&"  {
                  return yy::Parser::make_AND(ast::op_type::AND, loc);
               }

<INITIAL>"!"  {
                  return yy::Parser::make_NOT(ast::op_type::NOT, loc);
              }

<INITIAL>"to" {
                return yy::Parser::make_TO(loc);
              }

<INITIAL>"pure" {
                  return yy::Parser::make_PURE(loc);
                }

<INITIAL>"entry"  {
                    return yy::Parser::make_ENTRY(loc);
                  }

<INITIAL>"return" {
                    return yy::Parser::make_RTN(loc);
                  }

<INITIAL>"var"  {
                  return yy::Parser::make_VAR(loc);
                }

<INITIAL>"const"  {
                    return yy::Parser::make_CONST(loc);
                  }

<INITIAL>"func"   {
                    return yy::Parser::make_FUNC(loc);
                  }

<INITIAL>"true" {
                  return yy::Parser::make_LOGIC(true, loc);
                }

<INITIAL>"false"  {
                    return yy::Parser::make_LOGIC(false, loc);
                  }

<INITIAL>"import" {
                    return yy::Parser::make_IMPORT(loc);
                  }

<INITIAL>"export" {
                    return yy::Parser::make_EXPORT(loc);
                  }

<INITIAL>"struct" {
                    return yy::Parser::make_STRUCT(loc);
                  }

<INITIAL>"while"  {
                    return yy::Parser::make_WHILE(loc);
                  }

<INITIAL>"if" {
                return yy::Parser::make_IF(loc);
              }

<INITIAL>"elif"  {
                    return yy::Parser::make_ELIF(loc);
                  }

<INITIAL>"else" {
                  return yy::Parser::make_ELSE(loc);
                }

<INITIAL>{int}  {
                  errno = 0;
                  long n = strtol (yytext, NULL, 10);
            
                  if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
                    driver.error (loc, "integer is out of range");
            
                  return yy::Parser::make_INTEGER(n, loc);
                }

<INITIAL>{int}\.{int} {
                        errno = 0;
                        double n = strtod(yytext, NULL);
                        // TODO: error handling here
                        return yy::Parser::make_REAL(n, loc);
                      }

<INITIAL>[A-Za-z][0-9a-zA-Z]* { 
                                return yy::Parser::make_ID(yytext, loc);
                              }

<INITIAL>\"(\\.|[^"\\])*\"  {
                              // TODO: avaliar se é melhor fazer este escaneamento usando outro estado 
                              std::string str(yytext);
                              return yy::Parser::make_STR(str.substr(1,str.size()-2), loc);
                            }

<INITIAL>.  {
              driver.error(loc, "lexical error, unexpected "+std::string(yytext));
            }

<INITIAL><<EOF>>  {
                    return yy::Parser::make_END(loc);
                  }

<MULT_COMMENT>".-"  {
                      // aqui termina o comentário multline
                      loc.step();
                      BEGIN(INITIAL);
                    }

<MULT_COMMENT>. {
                  loc.step();
                }

<MULT_COMMENT>[\n]+ {
                      loc.lines(yyleng); 
                      loc.step();
                    }

<MULT_COMMENT><<EOF>> {
                        driver.error(loc, "lexical error, unexpected end of file expecting -|");
                        std::exit(1);
                      }

%%
