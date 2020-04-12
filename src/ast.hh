#pragma once

#include <string>
#include <memory>

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
  std::unique_ptr<Block> block;

  // Exibe a estrutura da AST num formato semelhante ao JSON,
  // isto foi adicionado para fins de debug.
  void print();
};

struct Expression
{
  std::unique_ptr<Object> object;
  std::unique_ptr<Expression> expr, lExpr, rExpr;
  bool operatorPlus = false, operatorMinus = false, operatorMult = false,
       operatorDiv = false, operatorMod = false;

  void print(int level);
};

struct Assign
{
  std::unique_ptr<Expression> expr;
  std::unique_ptr<Var> var;

  void print(int level);
};

struct Number
{
  std::unique_ptr<int> integer;
  std::unique_ptr<float> real;

  void print(int level);
};

struct Object
{
  std::unique_ptr<FunctionCall> functionCall;
  std::unique_ptr<Number> number;
  std::unique_ptr<std::string> text;
  std::unique_ptr<bool> logic;

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
