#include "ast.hh"
#include <iostream>
namespace ast = dione::ast;

void
// ast root
ast::Dione::print()
{
  int level = 0;
  std::cout << "dione : {" << std::endl;

  if (block != nullptr)
    block->print(level++);

  std::cout << "}" << std::endl;
}