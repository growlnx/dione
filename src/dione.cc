#include "cli.hh"
#include "driver.hh"
#include <iostream>

namespace cli = dione::cli;
namespace driver = dione::driver;

int
main(int argc, char* argv[])
{

  cli::Cli* args = cli::parse(argc, argv);

  if (args == nullptr)
    return 1;

  driver::Driver driver;
  driver.trace_parsing = args->parseTrace;
  driver.trace_scanning = args->lexerTrace;

  // TODO: threaded parsing
  for (std::string file : args->fileNames)
    driver.parse(file);

  delete args;

  return 0;
}
