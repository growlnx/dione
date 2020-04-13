#pragma once

#include <memory>
#include <string>

namespace dione {
namespace ast {

struct Dione;
struct Block;
struct Expression;
struct Assign;
struct Number;
struct Object;
struct FunctionCall;
struct Var;
struct CmdList;
struct Namespace;

struct Dione
{
  std::unique_ptr<ast::Block> block;

  // Exibe a estrutura da AST num formato semelhante ao JSON,
  // isto foi adicionado para fins de debug.
  void print();
};

enum op_type
{
  MINUS,
  PLUS,
  DIV,
  MULT,
  MOD
};

struct Expression
{
  std::unique_ptr<ast::Object> object;
  std::unique_ptr<ast::Expression> expr, lExpr, rExpr;
  ast::op_type op;

  Expression();
  Expression(std::unique_ptr<ast::Object> object);
  Expression(std::unique_ptr<ast::Expression> expr);
  Expression(std::unique_ptr<ast::Expression> lExpr,
             ast::op_type op,
             std::unique_ptr<ast::Expression> rExpr);

  void print(int level);
};

struct Assign
{
  std::unique_ptr<ast::Expression> expr;
  std::unique_ptr<ast::Var> var;

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
  // concatena valor numérico no início da string
  // 0+"1234" -> "01234"
  std::unique_ptr<std::string> add(std::unique_ptr<std::string> text);
  std::unique_ptr<ast::Number> sub(std::unique_ptr<ast::Number> number);
  std::unique_ptr<ast::Number> mult(std::unique_ptr<ast::Number> number);
  // concatena a propria string a si mesma N vezes
  // 10*"1" -> "1111111111"
  // std::unique_ptr<std::string> mult(std::unique_ptr<std::string> text);
  std::unique_ptr<ast::Number> div(std::unique_ptr<ast::Number> number);
  std::unique_ptr<ast::Number> mod(std::unique_ptr<ast::Number> number);

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
  Object(std::unique_ptr<ast::Number> number);
  Object(std::unique_ptr<std::string> text);

  // TODO
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
  // TODO
  void print(int level);
};

struct CmdList
{
  // TODO
  void print(int level);
};

struct Block
{
  // TODO
  void print(int level);
};

}
}
