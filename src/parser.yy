%skeleton "lalr1.cc" // -*- C++ -*-
%require "3.4"

%defines
%define lr.type ielr
%define api.parser.class {Parser}
%define api.token.prefix {TOKEN_}
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define parse.trace
%define parse.error verbose

%code requires {
#include <string>
#include <iostream>
#include <memory>
#include "ast.hh"

namespace dione {
namespace driver {
class Driver;
} // namespace driver
} // namespace dione

namespace ast = dione::ast;
namespace driver = dione::driver;
}

// The parsing context.
%param {driver::Driver& driver}

%locations

%initial-action
{
  // Initialize the initial location.
  @$.begin.filename = @$.end.filename = &driver.file;
};

%code {
#include "driver.hh"
#include <memory>
#include <variant>

namespace ast = dione::ast;
}

// delimitadores
%token END 0  "end of file"
%token L_PRT  "("
%token R_PRT  ")"
%token L_BCK  "["
%token R_BCK  "]"
%token L_BRC  "{"
%token R_BRC  "}"
%token COMMA  ","
%token DOT    "."
%token SEMIC  ";"
//%token UNKNOW "?"
%token ARROW  "->"

// palavras reservadas - keywords
%token VAR    "var"
%token CONST  "const"
%token FUNC   "func"
%token IMPORT "import" 
%token EXPORT "export" 
%token WHILE  "while" 
%token IF     "if"
%token ELIF   "elif"
%token ELSE   "else"
%token PURE   "pure"
%token ENTRY  "entry"
%token RTN    "return"
%token STRUCT "struct"
%token TO     "to"

// operadores
%token <ast::op_type> MINUS  "-"
%token <ast::op_type> PLUS   "+"
%token <ast::op_type> MULT   "*"
%token <ast::op_type> DIV    "/"
%token <ast::op_type> MOD    "%"
%token <ast::op_type> AND    "&&"
%token <ast::op_type> OR     "||"
%token <ast::op_type> NOT    "!"
%token <ast::op_type> B_AND  "&"
%token <ast::op_type> B_OR   "|"
%token <ast::op_type> B_NOT  "~"
%token <ast::op_type> EQ     "=="
%token <ast::op_type> MAJ    ">"
%token <ast::op_type> MIN    "<"
%token <ast::op_type> N_EQ   "!="
%token <ast::op_type> MAJ_EQ ">="
%token <ast::op_type> MIN_EQ "<="
%token <ast::op_type> ASSIGN "="
%token <ast::op_type> REF    "@"
%token <ast::op_type> PRT    "^"

// literais
%token <bool>        LOGIC       "logic literal" 
%token <std::string> STR         "str literal"
%token <int>         INTEGER     "integer literal"
%token <float>       REAL        "real literal"
%token <std::string> ID          "identifier"

// precedência, aumenta conforme as linhas
%left OR AND
%left ASSIGN
%left EQ N_EQ MAJ MAJ_EQ MIN MIN_EQ
%left PLUS MINUS
%left MULT DIV MOD
%left B_AND B_OR
%right NEG POS NOT
%right B_NOT

%nterm <ast::GlobalEscope> opt_global_escope
%nterm <ast::VarDef> var_def const_def
%nterm <bool> opt_vis
%nterm <ast::expression> expr
%nterm <std::unique_ptr<ast::PrimaryExpression>> prim_expr
%nterm <std::optional<ast::expression>> opt_init
%nterm <std::optional<ast::type>> opt_type
%nterm <ast::type> type
%nterm <ast::data_type> data

%nterm <std::optional<ast::op_type>>opt_type_mod
//%nterm <ast::LocalEscope> opt_local_escope

%start dione;

%%

dione
  : opt_global_escope
  {
    $1.print(1);
  }
  ;

opt_global_escope
  : %empty
  {
    $$.check();
  }
  | opt_global_escope opt_vis const_def
  {
    $3.exported = std::move($2);
    $1.statements.push_back(std::move($3));
    $$ = std::move($1);
  }
  | opt_global_escope opt_vis var_def
  {
    $3.exported = std::move($2);
    $1.statements.push_back(std::move($3));
    $$ = std::move($1);
  }
  // | opt_vis func_def opt_global_escope
  // | opt_global_escope "import" "var" ID  type ";"
  // | opt_global_escope "import" "const" ID type ";" 
  // | opt_global_escope "import" opt_func_attr "func" ID opt_func_param opt_func_rtn ";"
  // | opt_global_escope struct_def
  ;

//opt_loc_escope
//  : %empty
//  | "{" opt_loc_escope "}" opt_loc_escope
//  | var_def opt_loc_escope
//  | const_def opt_loc_escope
//   | expr ";" opt_loc_escope
//   | while_loop opt_loc_escope
//   | if_cond opt_loc_escope
//   | "return" expr ";" opt_loc_escope
  ;
 
var_def
  : "var" ID opt_init opt_type ";"
  {
    $$.id = std::move($2);
    $$.id_loc = std::move(@2);

    if($3) {
      $$.value = std::move($3);
      $$.value_loc = std::move(@3);
    }

    if($4) {
      $$.var_type = std::move($4);
      $$.var_type_loc = std::move(@4);
    } 
  }
  ;

opt_init
  : %empty
  {
    $$ = std::nullopt;
  }
  | "=" expr
  {
    $$ = std::move($2);
  }
  ;

const_def
  : "const" ID "=" expr opt_type ";"
  {
    $$.id = std::move($2);
    $$.id_loc = std::move(@2);

    $$.value = std::move($4);
    $$.value_loc = std::move(@4);

    if($5) {
      $$.var_type = std::move($5);
      $$.var_type_loc = std::move(@5);
    }
  }
  ;

opt_type
  : %empty
  {
    $$ = std::nullopt;
  }
  | type
  {
    $$ = std::move($1);
  }
  ;

type
  // built-in types
  : opt_type_mod ID
  {
    $$ = std::make_pair(std::move($1), std::move($2));
  }
  ;

opt_type_mod
  : %empty
  {
    $$ = std::nullopt;
  }
  // referência
  | "@"
  {
    $$ = ast::op_type::REF;
  }
  // ponteiro
  | "^"
  {
    $$ = ast::op_type::PRT;
  }
  ;

opt_vis
  : %empty
  {
    $$ = false;
  }
  | "export"
  {
    $$ = true;
  }
  ;

// func_def
//   : opt_func_attr "func" ID opt_func_param opt_func_rtn "{" opt_loc_escope "}"
//   ;

// opt_func_attr
//   : %empty
//   | "pure"
//   | "entry"
//   ;

// opt_func_param
//   : %empty
//   | typed_var
//   | "(" param_ls ")"
//   ;

// param_ls
//   : typed_var
//   | typed_var "," param_ls
//   ;

// typed_var
//   : ID type
//   ;

// opt_func_rtn
//   : %empty
//   | "->" type
//   ;

expr
  : prim_expr
  {
    $$ = std::move($1);
  }
  // prt
  //| "*" prim_expr %prec PRT
  //| "&" prim_expr %prec REF
  // algebra básica
  //| "-" prim_expr %prec NEG
  //| "+" prim_expr %prec POS
  //| expr "+" expr
  // | expr "-" expr
  // | expr "*" expr
  // | expr "/" expr
  // | expr "%" expr
  // bitwise
  // | "~" prim_expr
  // | expr "&" expr
  // | expr "|" expr
  // comparação
  // | "!" prim_expr
  // | expr "&&" expr
  // | expr "||" expr
  // | expr "==" expr
  // | expr "!=" expr
  // | expr ">"  expr
  // | expr ">=" expr
  // | expr "<"  expr
  // | expr "<=" expr
  // atribuição
  // | ID "=" expr
  // func call
  // | FUNC_ID "(" opt_arg_ls ")"
  // | ID "(" opt_arg_ls ")"
  // | "(" expr ")" "(" opt_arg_ls ")"
  // array acess
  // | ID "[" expr "]"
  // | "(" expr ")" "[" expr "]"
  // casting
  // | "(" expr ")" "to" type
  ;

prim_expr
  : data
  {
    $$ = std::make_unique<ast::PrimaryExpression>();
    $$->value = std::move($1);
  }
  //  | prim_expr "." ID
  //  | prim_expr "->" ID
  | "(" expr ")"
  {
    $$->value = std::move($2);
  }
  ;

data
  : LOGIC
  {
    $$ = std::move($1);
  }
  | STR
  {
    $$ = std::move($1);
  }
  | INTEGER
  {
    $$ = std::move($1);
  }
  | REAL
  {
    $$ = std::move($1);
  }
  | ID
  {
    $$ = std::move($1);
  }
  ;

opt_arg_ls
  : %empty
  | expr
  | expr "," opt_arg_ls
  ;

// while_loop
//   : "while" expr "{" opt_loc_escope "}"
//   ;

// if_cond
//   : "if" expr "{" opt_loc_escope "}" opt_elif_cond opt_else_cond
//   ;

// opt_elif_cond
//   : %empty
//   | "elif" expr "{" opt_loc_escope "}" opt_elif_cond
//   ;

// opt_else_cond
//   : %empty
//   | "else" "{" opt_loc_escope "}"
//   ;

// struct_def
//   : "struct" ID "{" param_ls "}"
//   ;

%%

void
yy::Parser::error(const location_type& loc, const std::string& msg)
{
  driver.error(loc, msg);
}
