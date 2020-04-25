#include "ast.hh"
#include "location.hh"
#include <iostream>

namespace ast = dione::ast;

ast::Expression::~Expression()
{
  delete object;
  delete expression;
  delete parentheses_expression;
  delete left_expression;
  delete right_expression;
}

std::string
ast::Expression::print(int ident_level)
{
  std::string node = "\n" + std::string(ident_level, ' ') + "expression {\n";

  if (object)
    node += object->print(ident_level + 1);
  else if (op) {

    node += std::string(ident_level + 1, ' ') + "operator => ";

    switch (op) {
      case ast::op_type::PLUS:
        node += "+";
        break;
      case ast::op_type::MINUS:
        node += "-";
        break;
      case ast::op_type::MULT:
        node += "*";
        break;
      case ast::op_type::DIV:
        node += "/";
        break;
      case ast::op_type::MOD:
        node += "%";
        break;
      case ast::op_type::L_ASS:
        node += "<<";
        break;
      case ast::op_type::R_ASS:
        node += ">>";
        break;
      case ast::op_type::SWAP:
        node += "><";
        break;
    }

    node += left_expression->print(ident_level + 1);
    node += right_expression->print(ident_level + 1);
  }

  node += "\n" + std::string(ident_level, ' ') + "}";

  return node;
}

ast::expression_type 
ast::Expression::getType()
{
  if(object != nullptr) return object->getType();

  if(left_expression != nullptr and right_expression != nullptr) {
    left_expression_type = left_expression->getType();

    if(left_expression_type == ast::expression_type::T_INVALID) 
      return nullptr;

    right_expression_type = right_expression->getType();

    if(right_expression_type == ast::expression_type::T_INVALID) 
      return nullptr;

    if(right_expression_type == left_expression_type) 
      return right_expression_type;

    if(not (left_expression.isNumber() and right_expression.isNumber()))
      driver.error(op_loc, "semantic error, incompatible types in expression");
    
  }

  return ast::expression_type::T_INVALID;
}

void
ast::Expression::optimize()
{
  // TODO
}

void
ast::Expression::generateCode()
{
  // TODO
}