#include "ast.hh"
#include <iostream>

namespace ast = dione::ast;

ast::Number::Number() {}

ast::Number::Number(int integer)
{
  this->integer = std::make_unique<int>(integer);
}

ast::Number::Number(float real)
{
  this->real = std::make_unique<float>(real);
}

std::unique_ptr<ast::Number>
ast::Number::add(std::unique_ptr<ast::Number> number)
{
  if (not number)
    return nullptr;

  if (this->integer and number->integer) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer + *number->integer));

  } else if (this->integer and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer + *number->real));

  } else if (this->real and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->real + *number->real));

  } else if (this->real and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->real + *number->real));
  }

  return nullptr;
}

std::unique_ptr<std::string>
ast::Number::add(std::unique_ptr<std::string> text)
{
  if (not text)
    return nullptr;

  if (this->integer) {
    return std::move(
      std::make_unique<std::string>(std::to_string(*this->integer) + *text));

  } else if (this->real) {
    return std::move(
      std::make_unique<std::string>(std::to_string(*this->real) + *text));
  }

  return nullptr;
}

std::unique_ptr<ast::Number>
ast::Number::sub(std::unique_ptr<ast::Number> number)
{
  if (not(number))
    return nullptr;

  if (this->integer and number->integer) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer - *number->integer));

  } else if (this->integer and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer - *number->real));

  } else if (this->real and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->real - *number->real));

  } else if (this->real and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->real - *number->real));
  }

  return nullptr;
}

std::unique_ptr<ast::Number>
ast::Number::mult(std::unique_ptr<ast::Number> number)
{
  if (not number)
    return nullptr;

  if (this->integer and number->integer) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer * *number->integer));

  } else if (this->integer and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer * *number->real));

  } else if (this->real and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->real * *number->real));

  } else if (this->real and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->real * *number->real));
  }

  return nullptr;
}

std::unique_ptr<ast::Number>
ast::Number::div(std::unique_ptr<ast::Number> number)
{
  if (not(number))
    return nullptr;

  if (this->integer and number->integer) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer / *number->integer));

  } else if (this->integer and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer / *number->real));

  } else if (this->real and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->real / *number->real));

  } else if (this->real and number->real) {
    return std::move(
      std::make_unique<ast::Number>(*this->real / *number->real));
  }

  return nullptr;
}

std::unique_ptr<ast::Number>
ast::Number::mod(std::unique_ptr<ast::Number> number)
{
  if (not number)
    return nullptr;

  if (this->integer and number->integer) {
    return std::move(
      std::make_unique<ast::Number>(*this->integer % *number->integer));
  }

  return nullptr;
}

void
ast::Number::print(int level)
{
  level++;

  std::cout << std::string(level, ' ') << "number : ";

  if (integer != nullptr)
    std::cout << *integer << std::endl;

  else if (real != nullptr)
    std::cout << *real << std::endl;
}
