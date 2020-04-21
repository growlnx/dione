#pragma once

#include "parser.hh"
#include <string>
#include <map>
#include <variant>
#include <unordered_map>

// Tell Flex the lexer's prototype ...
# define YY_DECL \
  yy::Parser::symbol_type yylex (driver::Driver& driver)

// ... and declare it for the parser's sake.
YY_DECL;

namespace dione {
namespace driver {
// Conducting the whole scanning and parsing of Dione.
struct Driver
{
 
  bool trace_parsing, trace_scanning, optimize;
  std::string file;
  std::unordered_map<std::string, std::variant<std::nullptr_t, int, float>> vars; 
  int result;

  Driver();
  virtual ~Driver();

  // Handling the scanner.
  void scan_begin();
  void scan_end();
  
  // call the bison generated parser
  int parse (const std::string& f);
  
  bool varExists(std::string var);

  // Error handling.
  void error(const yy::location& loc, const std::string& msg);
  void error(const std::string& msg);
};
}
}
