#include "cli.hh"
#include "driver.hh"
#include <iostream>

namespace cli = oberon::cli;

int
main(int argc, char* argv[])
{

  cli::Cli* args = cli::parse(argc, argv);

  if (args == nullptr)
    return 1;

  Driver driver;
  driver.trace_parsing = args->parseTrace;
  driver.trace_scanning = args->lexerTrace;

  // TODO: threaded parsing
  for (std::string file : args->fileNames)
    driver.parse(file);

  delete args;

  return 0;
}
