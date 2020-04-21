#include "driver.hh"
#include "parser.hh"
#include <cstring>
#include <iostream>
#include <fstream>

extern int yy_flex_debug;
extern FILE* yyin;


namespace driver = driver;

driver::Driver::Driver()
{}

driver::Driver::~Driver()
{}

int
driver::Driver::parse(const std::string &f)
{
  file = f;
  scan_begin ();
  yy::Parser parser (*this);
  parser.set_debug_level (trace_parsing);
  int res = parser.parse ();
  scan_end ();
  return res;
}

void
// FIXME: melhorar a forma de reportar o error, 
//        talvez há uma maneira de reportar sem precisar ler o arquivo novamente
driver::Driver::error (const yy::location& loc, const std::string& msg)
{
  std::string err_line;
  std::ifstream filestream(file);
  
  for(int i=loc.begin.line; i >= 1; --i)
    std::getline(filestream, err_line, '\n');

  std::cerr << "Dione:"
            << file
            << ":"
            << loc
            << ": "
            << msg
            << "\n   "
            << loc.begin.line 
            << " | \033[31m"
            << err_line
            << "\033[0m"
            << "\n"
            << std::string(loc.begin.column+6, ' ')
            << std::string((loc.end.column-loc.begin.column == 0)? 1: loc.end.column-loc.begin.column, '^')
            << std::endl;
  
  exit(1);
}

void
driver::Driver::error (const std::string& msg)
{
  std::cerr << msg << std::endl;
  exit(1);
}

void
driver::Driver::scan_begin() 
{
  yy_flex_debug = trace_scanning;

  if (file.empty () || file == "stdin") {
    yyin = stdin;
  
  } else if (not(yyin = fopen (file.c_str (), "r"))) {
    error("cannot open " + file + ": " + strerror(errno));
    exit(EXIT_FAILURE);
  }
}

void
driver::Driver::scan_end()
{
  fclose(yyin);
}

bool 
driver::Driver::varExists(std::string var)
{
  return vars.find(var) != vars.end();
}