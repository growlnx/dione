#include "ast.hh"
#include <iostream>

namespace ast = dione::ast;

ast::Object::Object() {}

ast::Object::Object(std::string text)
{
  this->text= std::make_unique<std::string>(text);
}

ast::Object::Object(std::unique_ptr<ast::Number> number)
{
  this->number = std::move(number);
}

ast::Object::Object(std::unique_ptr<std::string> text)
{
  this->text= std::move(text);
}

std::unique_ptr<ast::Object>
ast::Object::add(std::unique_ptr<ast::Object> object)
{
  if (not object)
    return nullptr;

  if (this->number) {

    if (object->number) {
      return std::move(std::make_unique<ast::Object>(
        std::move(this->number->add(std::move(object->number)))));

    } else if (object->text) {
      return std::move(
        std::make_unique<ast::Object>(std::move(this->number->add(std::move(object->text)))));
    }
  }
  /*else if (this->text) {

    if (object->number) {
      return std::move(
        std::make_unique<ast::Object>(this->text + object->number));

    } else if (object->text) {
      return std::move(
        std::make_unique<ast::Object>(this->text + object->text));
    }

  }*/

  return nullptr;
}

std::unique_ptr<ast::Object>
ast::Object::sub(std::unique_ptr<ast::Object> object)
{
  if (not object)
    return nullptr;

  if (object->number) {
    return std::move(std::make_unique<ast::Object>(
      std::move(this->number->sub(std::move(object->number)))));
  }

  return nullptr;
}

std::unique_ptr<ast::Object>
ast::Object::mult(std::unique_ptr<ast::Object> object)
{
  if (not object)
    return nullptr;

  if (object->number) {
    return std::move(std::make_unique<ast::Object>(
      std::move(this->number->mult(std::move(object->number)))));
  }

  return nullptr;
}

std::unique_ptr<ast::Object>
ast::Object::div(std::unique_ptr<ast::Object> object)
{
  if (not object)
    return nullptr;

  if (object->number) {
    return std::move(std::make_unique<ast::Object>(
      std::move(this->number->div(std::move(object->number)))));
  }

  return nullptr;
}

std::unique_ptr<ast::Object>
ast::Object::mod(std::unique_ptr<ast::Object> object)
{
  if (not object)
    return nullptr;

  if (object->number) {
    return std::move(std::make_unique<ast::Object>(
      std::move(this->number->mod(std::move(object->number)))));
  }

  return nullptr;
}

void
ast::Object::print(int level)
{
  level++;

  std::cout << std::string(level, ' ') << "object : {" << std::endl;

  if (functionCall != nullptr)
    functionCall->print(level);

  else if (number != nullptr)
    number->print(level);

  else if (text != nullptr)
    std::cout << std::string(level + 1, ' ') << "text : " << *text
              << std::endl;

  else if (logic != nullptr)
    std::cout << std::string(level + 1, ' ')
              << "logic : " << ((*logic) ? "true" : "false") << std::endl;

  std::cout << std::string(level, ' ') << "}" << std::endl;
}