#pragma once

#include "location.hh"
#include <list>
#include <memory>
#include <optional>
#include <string>
#include <variant>
#include <vector>

namespace dione {
namespace ast {

enum op_type
{
  MINUS,
  PLUS,
  DIV,
  MULT,
  MOD,
  AND,
  OR,
  NOT,
  ASSIGN,
  SWAP,
  PRT,
  REF
};

enum expression_type
{
  T_LOGIC,
  T_TEXT,
  T_CHAR,
  T_INTEGER,
  T_REAL,
  T_INVALID,
  T_UNKNOW
};

class GlobalEscope;
class LocalEscope;
class VarDef;
class FuncDef;
class BinaryExpression;
class UnaryExpression;
class PrimaryExpression;
class FuncCall;
class ArrayAcess;
class NodeInterface;

class NodeInterface
{
protected:
  bool checked = false;

public:
  virtual void print(int ident) = 0;
  virtual void check() = 0;
  inline bool isChecked() const { return checked; }
  virtual void generate() = 0;
};

typedef std::variant<std::unique_ptr<
  PrimaryExpression> /*
,BinaryExpression,
UnaryExpression,
ArrayAcess,
FuncCall
*/>
  expression;

class BinaryExpression : public NodeInterface
{
public:
  std::unique_ptr<expression> lValue;
  std::unique_ptr<expression> rValue;
  op_type op;
  inline void print(int ident) override {}
  inline void check() override {}
  inline void generate() override {}
};

class UnaryExpression : public NodeInterface
{
public:
  std::unique_ptr<expression> value;
  op_type op;
  inline void print(int ident) override {}
  inline void check() override{};
  inline void generate() override{};
};

typedef std::variant<int, float, bool, std::string> data_type;

class PrimaryExpression : public NodeInterface
{
public:
  std::variant<data_type, expression> value;
  inline void print(int ident) override {}
  inline void check() override {}
  inline void generate() override {}
};

class FuncCall : public NodeInterface
{
public:
  std::string id;
  // std::list<expression> argument_list;
  inline void print(int ident) override {}
  inline void check() override{};
  inline void generate() override{};
};

class ArrayAcess : public NodeInterface
{
public:
  inline void print(int ident) override {}
  inline void check() override{};
  inline void generate() override{};
};

typedef std::variant<VarDef> global_statement;
typedef std::vector<global_statement> global_statement_list;

class FuncDef
{};

typedef std::pair<std::optional<op_type>, std::string> type;

class VarDef : NodeInterface
{
public:
  bool exported = false;
  bool immutable = true;

  std::string id;
  yy::location id_loc;

  std::optional<type> var_type;
  std::optional<yy::location> var_type_loc;

  std::optional<expression> value;
  std::optional<yy::location> value_loc;

  inline void print(int ident) override
  {
    std::string type = "None";

    if(not var_type->second.empty()) {
      
      type = var_type->second;
    
      if (var_type and var_type->first) {
        if (*var_type->first == op_type::PRT) {
          type = "^" + type;
        } else if (*var_type->first == op_type::REF) {
          type = "@" + type;
        }
      }

    }


    std::string space = std::string(ident * 4, ' ');
    std::cout << space << "<Var Define> : {\n"
              << space << space << "id : " << id << "\n"
              << space << space << "type : " << type << "\n"

              << space << "}" << std::endl;
  }
  inline void check() override{};
  inline void generate() override{};
};

class GlobalEscope : public NodeInterface
{
public:
  global_statement_list statements;
  inline void print(int ident) override
  {
    for (int i = 0; i < statements.size(); ++i) {
      std::get<VarDef>(statements[i]).print(ident);
    }
  }
  inline void check() override{};
  inline void generate() override{};
};

typedef std::variant<LocalEscope, VarDef, expression> local_statement;
typedef std::list<local_statement> local_statement_list;

class LocalEscope : public NodeInterface
{
public:
  std::optional<local_statement_list> statements;
  inline void print(int ident) override {}
  inline void check() override{};
  inline void generate() override {}
};

} // namespace ast
} // namespace dione
