#include "cli.hh"
#include <string>
#include <iostream>

namespace cli = oberon::cli;

cli::Cli* 
cli::parse(int argc, char** argv)
{
  cli::Cli* _cli = new cli::Cli();

  if(argc < 2) help(); 

  for(int i=1; i < argc; ++i) {
    std::string arg(argv[i]);
    
    if(arg == "-pt" or arg == "--parser-trace"){
      _cli->parseTrace = true;

    } else if(arg == "-lt" or arg == "--lexer-trace") {
     _cli->lexerTrace = true;
    
    } if(arg == "-h" or arg == "--help") {
      help();
      return nullptr;

    } else if(arg == "-v" or arg == "--version") {
    
    } else if (arg[0] != '-'){ // if not an argument... 
      _cli->fileNames.push_back(arg);

    } else {
      std::cerr << "invalid cli argument: " << arg << std::endl;
      exit(1);
    }

  }

  return _cli;
}

void
cli::help()
{
  std::cout << "HELP MSG\n";
}
