#pragma once

#include <memory>
#include <string>
#include "location.hh"

namespace dione {
namespace ast {

enum op_type
{
  MINUS,
  PLUS,
  DIV,
  MULT,
  MOD,
  L_ASS,
  R_ASS,
  SWAP
};

struct Node;
struct Dione;
struct Block;
struct Expression;
struct Number;
struct Object;
struct Var;
struct Statements;
struct MainScope;
struct ConditionalScope;
struct FunctionScope;

struct Node
{
  virtual std::string print(int ident_level) = 0;
  // virtual void checkSemantic() = 0;
  virtual void optimize() = 0;
  virtual void generateCode() = 0;
};

struct Dione : public Node
{
  // TODO: implementar AST
};

struct Expression : public Node
{
  yy::location left_expr_loc; 
  yy::location right_expr_loc;

  yy::location op_loc; 
  ast::op_type op;

  yy::location object_loc; 
  ast::Object *object;

  yy::location expression_loc; 
  ast::Expression *expression;

  yy::location parentheses_expression_loc;
  ast::Expression *parentheses_expression;

  yy::location left_expression_loc;
  ast::Expression *left_expression;

  yy::location right_expression_loc;
  ast::Expression *right_expression;
  
  bool negative_signal = false;

  virtual ~Expression();

  void optimize() override;

  void generateCode() override;

  std::string print(int ident_level) override;
};


struct Object : public Node
{
  yy::location loc;
  bool* logic;
  char* character;
  std::string* text;
  int *integer;
  float *real;
  std::string* identifier;

  virtual ~Object();

  bool isNumber();

  void optimize() override;

  void generateCode() override;

  std::string print(int ident_level) override;
};


} // namespace ast
} // namespace dione
