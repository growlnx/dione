#include "ast.hh"
#include <iomanip>
#include <iostream>

namespace ast = dione::ast;

ast::Dione::~Dione()
{
  // TODO
}

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

ast::Expression::~Expression()
{
  // TODO
}

void
ast::Expression::print(int level)
{
  level++;

  std::cout << std::string(level, ' ') << "expression : {" << std::endl;

  if (object != nullptr)
    object->print(level);
  
  else if (expr != nullptr)
    expr->print(level);
  
  else if (lExpr != nullptr and rExpr != nullptr) {
    
    std::cout << std::string(level+1,' ') << "operator : ";

    if (operatorMinus)
      std::cout << "-" << std::endl;
    
    else if (operatorPlus)
      std::cout << "+" << std::endl;
    
    else if (operatorMult)
      std::cout << "*" << std::endl;
    
    else if (operatorDiv)
      std::cout << "/" << std::endl;
    
    else if (operatorMod)
      std::cout << "%" << std::endl;

    lExpr->print(level);
    rExpr->print(level);
  }

  std::cout << std::string(level, ' ') << "}" << std::endl;
}

/*ast::Operator::~Operator()
{
  //TODO
}*/

ast::Number::~Number()
{
  // TODO
}

void
ast::Number::print(int level)
{
  level++;

  std::cout << std::string(level, ' ') << "number : ";

  if (integer != nullptr)
    std::cout << *integer << std::endl;

  else if (real != nullptr)
    std::cout << *real << std::endl;
}

ast::Object::~Object()
{
  // TODO
}

void
ast::Object::print(int level)
{
  level++;

  std::cout << std::string(level, ' ') << "object : {" << std::endl;

  if (functionCall != nullptr)
    functionCall->print(level);

  else if (number != nullptr)
    number->print(level);

  else if (text != nullptr)
    std::cout << std::string(level + 1, ' ') << "\"text\" : " << text
              << std::endl;

  else if (logic != nullptr)
    std::cout << std::string(level + 1, ' ')
              << "\"logic\" : " << ((*logic) ? "true" : "false") << std::endl;

  std::cout << std::string(level, ' ') << "}" << std::endl;
}

void
ast::FunctionCall::print(int level)
{
  // TODO
}

void
ast::Block::print(int level)
{
  // TODO
}
