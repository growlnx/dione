#pragma once

#include <string>
#include <vector>

namespace dione {
namespace cli {

struct Cli
{
  std::vector<std::string> fileNames;
  unsigned verboseLevel;
  bool lexerTrace = false, parseTrace = false;

  Cli(int argc, char** argv);

  // exibe mensagem de ajuda
  void help();
};

} // cli
} // dione
