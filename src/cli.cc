#include "cli.hh"
#include <iostream>
#include <string>

namespace cli = dione::cli;

cli::Cli::Cli(int argc, char** argv)
{

  if (argc < 2)
    help();

  for (int i = 1; i < argc; ++i) {
    std::string arg(argv[i]);

    if (arg == "-pt" or arg == "--parser-trace") {
      parseTrace = true;

    } else if (arg == "-lt" or arg == "--lexer-trace") {
      lexerTrace = true;
    
    } else if (arg == "-h" or arg == "--help") {
      help();
      exit(1);

    } else if (arg == "-v" or arg == "--version") {

    } else if (arg[0] != '-') { // if not an argument...
      fileNames.push_back(arg);

    } else {
      std::cerr << "invalid cli argument: " << arg << std::endl;
      exit(1);
    }
  }
}

void
cli::Cli::help()
{
  // TODO: criar uma mensagem de ajuda
  std::cout << "HELP MSG\n";
}
