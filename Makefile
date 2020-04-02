.PHONY: clean build test

PROJECT	= oberon
CC	= g++
CFLAGS	= -ldl
SRC	= src
INCLUDE	= src/include
OBJ	= obj
DEST	= bin

all: 	clean build

build:
	bison -o $(SRC)/parser.cc $(SRC)/parser.yy
	
	mv $(SRC)/*.hh $(INCLUDE)
	
	flex  -o $(SRC)/lexer.cc $(SRC)/lexer.ll
	
	mkdir -p $(OBJ) $(DEST)
	
	$(CC) -I $(INCLUDE) -o $(OBJ)/driver.o     -c $(SRC)/driver.cc
	$(CC) -I $(INCLUDE) -o $(OBJ)/parser.o     -c $(SRC)/parser.cc
	$(CC) -I $(INCLUDE) -o $(OBJ)/lexer.o      -c $(SRC)/lexer.cc
	$(CC) -I $(INCLUDE) -o $(OBJ)/$(PROJECT).o -c $(SRC)/$(PROJECT).cc
	$(CC) -I $(INCLUDE) -o $(OBJ)/cli.o        -c $(SRC)/cli.cc
	
	$(CC) -I $(INCLUDE) -o $(DEST)/$(PROJECT) $(CFLAGS) $(OBJ)/*.o

clean:
	-rm -fr $(SRC)/parser.cc $(INCLUDE)/parser.hh $(SRC)/lexer.cc \
	$(INCLUDE)/location.hh $(INCLUDE)/position.hh 	 	\
	$(INCLUDE)/stack.hh $(OBJ) $(DEST)

test:
	bin/$(PROJECT) example/$(FILE)

