#include "ast.hh"
#include <iostream>

namespace ast = dione::ast;

ast::Object::~Object()
{
  delete logic;
  delete character;
  delete text;
  delete integer;
  delete real;
}

bool 
ast::Object::isNumber()
{
  return integer or real;
}


void 
ast::Object::optimize() 
{
  // TODO
}

void
ast::Object::generateCode()
{
  // TODO
};

std::string
ast::Object::print(int ident_level)
{
  std::string node = std::string(ident_level, ' ');
  node += "object => ";

  if(character)     node += *character;
  else if(text)     node += *text;
  else if(logic)    node += *logic ? "true" : "false";
  else if(integer)  node += std::to_string(*integer);
  else if(real)     node += std::to_string(*real);

  return node;
}