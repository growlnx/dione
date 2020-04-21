#pragma once

#include <string>
#include <vector>

namespace dione {
namespace cli {

struct Cli
{
  std::vector<std::string> fileNames;
  unsigned verboseLevel;
  bool lexerTrace = false; 
  bool parseTrace = false;
  bool optimize = true;
  
  Cli(int argc, char** argv);

  // exibe mensagem de ajuda
  void help();
};

} // cli
} // dione
