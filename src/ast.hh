#pragma once

#include <memory>
#include <string>

namespace dione {
namespace ast {

struct Dione;
struct Block;
struct Expression;
struct Number;
struct Object;
struct FunctionCall;
struct Var;
struct Statements;
struct MainScope;
struct ConditionalScope;
struct FunctionScope;

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

struct Dione
{
  // TODO: implementar AST
};

struct Expression
{
  std::unique_ptr<ast::Object> object;
  std::unique_ptr<ast::Expression> expr, lExpr, rExpr;
  ast::op_type op;
  bool negative_signal = false, positive_signal = false;

  Expression();
  Expression(std::unique_ptr<ast::Object> object);
  Expression(std::unique_ptr<ast::Expression> expr);
  Expression(std::unique_ptr<ast::Expression> lExpr,
             ast::op_type op,
             std::unique_ptr<ast::Expression> rExpr);

  void print(int level);
};

struct Number
{
  std::unique_ptr<int> integer;
  std::unique_ptr<float> real;

  Number();
  Number(int integer);
  Number(float real);

  std::unique_ptr<ast::Number> add(std::unique_ptr<ast::Number> number);
  std::unique_ptr<ast::Number> sub(std::unique_ptr<ast::Number> number);
  std::unique_ptr<ast::Number> mult(std::unique_ptr<ast::Number> number);
  std::unique_ptr<ast::Number> div(std::unique_ptr<ast::Number> number);
  std::unique_ptr<ast::Number> mod(std::unique_ptr<ast::Number> number);

  // concatena valor numérico no início da string
  // 0+"1234" -> "01234"
  std::unique_ptr<std::string> add(std::unique_ptr<std::string> text);
  // // 1-"asd" -> 
  // std::unique_ptr<ast::Number> sub(std::unique_ptr<ast::Number> text);
  // std::unique_ptr<ast::Number> mult(std::unique_ptr<ast::Number> number);
  // std::unique_ptr<ast::Number> div(std::unique_ptr<ast::Number> number);
  // std::unique_ptr<ast::Number> mod(std::unique_ptr<ast::Number> number);


  void print(int level);
};

struct Object
{
  std::unique_ptr<ast::FunctionCall> functionCall;
  std::unique_ptr<ast::Number> number;
  std::unique_ptr<std::string> text;
  std::unique_ptr<bool> logic;

  Object();
  Object(std::string text);
  // Object(bool logic);
  Object(std::unique_ptr<ast::Number> number);
  Object(std::unique_ptr<std::string> text);
  // TODO: implementar construtor para booleanos
  // Object(std::unique_ptr<bool>);

  std::unique_ptr<ast::Object> add(std::unique_ptr<ast::Object> object);
  std::unique_ptr<ast::Object> sub(std::unique_ptr<ast::Object> object);
  std::unique_ptr<ast::Object> mult(std::unique_ptr<ast::Object> object);
  std::unique_ptr<ast::Object> div(std::unique_ptr<ast::Object> object);
  std::unique_ptr<ast::Object> mod(std::unique_ptr<ast::Object> object);

  void print(int level);
};

struct FunctionCall
{
  // TODO: implementar ast
  // void print(int level);
};

struct Statements
{
  // TODO: implementar ast
  // void print(int level);
};

// escopo principal do programa,
// futuramente será modificado quando os namespaces forem implementados
struct MainScope
{
  // TODO: implementar ast
  // void print(int level);
};

struct ConditionalScope
{
  // TODO: implementar ast
  // void print(int level);
};

struct FunctionScope
{
  // TODO: implementar ast
  // void print(int level);
};

}
}
