#pragma once

#include <string>

namespace oberon {
namespace ast {

struct Oberon;
struct Block;
struct Expression;
struct Assign;
struct Operator;
struct Number;
struct Object;
struct FunctionCall;
struct Var;
struct CmdList;
struct Namespace;

struct Oberon
{
  Block* block;
};

struct Expression
{
  Object* object;
  Expression *expr, *lExpr, *rExpr;
  Operator* op;
};

struct Assign
{
  Expression* expr;
  Var* var;
};

struct Operator
{
  bool minus = false, plus = false, mult = false, div = false, mod = false,
       lAssign = false, rAssign = false;
};

struct Number
{
  int* integer;
  float* real;
};

struct Object
{
  FunctionCall* functionCall;
  Number* number;
  std::string* text;
  bool* logic;
};

struct functionCall
{
  // TODO
};

struct CmdList
{
  // TODO
};


struct Namespace
{
  CmdList* cmdList;
  Namespace* _namespace;
};

}
}
