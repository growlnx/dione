#include "ast.hh"
#include <iostream>

namespace ast = dione::ast;

ast::Expression::Expression() {}

ast::Expression::Expression(std::unique_ptr<ast::Object> object)
{
  this->object = std::move(object);
}

ast::Expression::Expression(std::unique_ptr<ast::Expression> expr)
{
  if (expr->object) {
    this->object = std::move(expr->object);

  } else if (expr->expr) {
    this->expr = std::move(expr->expr);

  } else {
    this->expr = std::move(expr);
  }
}

ast::Expression::Expression(std::unique_ptr<ast::Expression> lExpr,
                            op_type op,
                            std::unique_ptr<ast::Expression> rExpr)
{
  if (lExpr->object and rExpr->object) {

    if (rExpr->object) {

      switch (op) {
        case op_type::PLUS:
          object = std::move(lExpr->object->add(std::move(rExpr->object)));
          break;

        case op_type::MINUS:
          object = std::move(lExpr->object->sub(std::move(rExpr->object)));
          break;

        case op_type::MULT:
          object = std::move(lExpr->object->mult(std::move(rExpr->object)));
          break;

        case op_type::DIV:
          object = std::move(lExpr->object->div(std::move(rExpr->object)));
          break;

        case op_type::MOD:
          object = std::move(lExpr->object->mod(std::move(rExpr->object)));
          break;
      }
    }

  } else {
    this->lExpr = std::move(lExpr);
    this->op = op;
    this->rExpr = std::move(rExpr);
  }
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

    std::cout << std::string(level + 1, ' ') << "operator : ";

    switch (op) {
      case op_type::PLUS:
        std::cout << "+" << std::endl;
        break;

      case op_type::MINUS:
        std::cout << "-" << std::endl;
        break;

      case op_type::MULT:
        std::cout << "*" << std::endl;
        break;

      case op_type::DIV:
        std::cout << "/" << std::endl;
        break;

      case op_type::MOD:
        std::cout << "%" << std::endl;
        break;
    }

    lExpr->print(level);
    rExpr->print(level);
  }

  std::cout << std::string(level, ' ') << "}" << std::endl;
}