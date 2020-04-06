#pragma once

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
  Block* block;

  virtual ~Dione();
  void print();
};

struct Expression
{
  Object* object;
  Expression *expr, *lExpr, *rExpr;
  
  bool operatorPlus = false, operatorMinus = false, 
       operatorMult = false, operatorDiv = false,
       operatorMod = false;

  virtual ~Expression();
  void print(int level);
};

struct Assign
{
  Expression* expr;
  Var* var;

  virtual ~Assign();
  void print(int level);
};

struct Number
{
  int* integer;
  float* real;

  virtual ~Number();
  void print(int level);
};

struct Object
{
  FunctionCall* functionCall;
  Number* number;
  std::string* text;
  bool* logic;
  
  virtual ~Object();
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
