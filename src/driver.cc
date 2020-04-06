#include "driver.hh"
#include "parser.hh"
#include <cstring>

extern int yy_flex_debug;
extern FILE* yyin;


namespace driver = driver;

driver::Driver::Driver() : trace_scanning (false), trace_parsing (false)
{
  variables["one"] = 1;
  variables["two"] = 2;
}

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
driver::Driver::error (const yy::location& loc, const std::string& msg)
{
  std::cerr << "Dione:" <<  file << ":" << loc << ": " << msg << std::endl;
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
  
  } else if (!(yyin = fopen (file.c_str (), "r"))) {
    error("cannot open " + file + ": " + strerror(errno));
    exit(EXIT_FAILURE);
  }
}

void
driver::Driver::scan_end()
{
  fclose(yyin);
}
