#include "driver.hh"
#include "parser.hh"

Driver::Driver () : trace_scanning (false), trace_parsing (false)
{
  variables["one"] = 1;
  variables["two"] = 2;
}

Driver::~Driver ()
{
}

int
Driver::parse (const std::string &f)
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
Driver::error (const yy::location& loc, const std::string& msg)
{
  std::cerr << "Oberon:" <<  file << ":" << loc << ": " << msg << std::endl;
  exit(1);
}

void
Driver::error (const std::string& msg)
{
  std::cerr << msg << std::endl;
  exit(1);
}
