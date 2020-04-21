#include "cli.hh"
#include "driver.hh"
#include "ast.hh"
#include <iostream>

namespace cli = dione::cli;
namespace driver = dione::driver;

int
main(int argc, char** argv)
{
  cli::Cli args(argc, argv);

  driver::Driver driver;
  driver.trace_parsing = args.parseTrace;
  driver.trace_scanning = args.lexerTrace;
  driver.optimize = args.optimize;

  // TODO: realizar o parsing de cada arquivo em uma thread diferente
  for (std::string file : args.fileNames) {
    driver.parse(file);
  }

  return 0;
}
