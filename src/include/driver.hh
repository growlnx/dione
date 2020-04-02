#pragma once

#include <string>
#include <map>
#include "parser.hh"

// Tell Flex the lexer's prototype ...
# define YY_DECL \
  yy::Parser::symbol_type yylex (Driver& driver)

// ... and declare it for the parser's sake.
YY_DECL;

// Conducting the whole scanning and parsing of Oberon.
struct Driver
{
 
  bool trace_parsing, trace_scanning;
  std::string file;
  std::map<std::string, int> variables; 
  int result;

  Driver();
  virtual ~Driver();

  // Handling the scanner.
  void scan_begin();
  void scan_end();
  
  // call the bison generated parser
  int parse (const std::string& f);
  
  // Error handling.
  void error (const yy::location& loc, const std::string& msg);
  void error (const std::string& msg);
};

