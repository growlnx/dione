#pragma once

#include <vector>
#include <string>

namespace oberon {
namespace cli {

struct Cli {
  std::vector<std::string> fileNames;
  unsigned verboseLevel;
  bool lexerTrace = false, parseTrace = false;
};

Cli* 
// do cli args parsing
parse(int argc, char** argv);

void
// show help msg
help();

} // cli
} // oberon

