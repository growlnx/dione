#pragma once

#include <memory>
#include <string>
#include "location.hh"
#include <fstream>

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


} // namespace ast
} // namespace dione
