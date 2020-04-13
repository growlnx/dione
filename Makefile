.PHONY: clean build test

PROJECT	= dione
CC	= g++
CFLAGS	= -ldl -O2 -ggdb
SRC	= src
LIB     = lib/
OBJ	= obj
DEST	= bin

all: 	clean build

install: 
	sudo cp bin/dione /usr/bin/dione

unistall:  
	sudo rm bin/dione /usr/bin/dione

build:
	@echo "[DIONE] build started"
	bison -o $(SRC)/parser.cc $(SRC)/parser.yy
		
	flex  -o $(SRC)/lexer.cc $(SRC)/lexer.ll
	
	mkdir -p $(DEST) $(OBJ)

	$(CC) -o $(OBJ)/driver.o     		-c $(SRC)/driver.cc
	$(CC) -o $(OBJ)/parser.o     		-c $(SRC)/parser.cc
	$(CC) -o $(OBJ)/dione_ast.o   		-c $(SRC)/dione_ast.cc
	$(CC) -o $(OBJ)/number_ast.o   		-c $(SRC)/number_ast.cc
	$(CC) -o $(OBJ)/object_ast.o   		-c $(SRC)/object_ast.cc
	$(CC) -o $(OBJ)/expression_ast.o   	-c $(SRC)/expression_ast.cc
	$(CC) -o $(OBJ)/block_ast.o   		-c $(SRC)/block_ast.cc
	$(CC) -o $(OBJ)/function_call_ast.o -c $(SRC)/function_call_ast.cc
	$(CC) -o $(OBJ)/lexer.o      		-c $(SRC)/lexer.cc
	$(CC) -o $(OBJ)/$(PROJECT).o 		-c $(SRC)/$(PROJECT).cc
	$(CC) -o $(OBJ)/cli.o        		-c $(SRC)/cli.cc
	
	$(CC) -o $(DEST)/$(PROJECT) $(CFLAGS) $(OBJ)/*.o
	@echo   "[DIONE] build finished"
clean:
	@echo "[DIONE] clean started"
	-rm -rf $(SRC)/parser.cc $(SRC)/parser.hh $(SRC)/lexer.cc \
	$(SRC)location.hh $(SRC)/position.hh                  	  \
	$(SRC)/stack.hh $(OBJ) $(DEST)
	@echo "[DIONE] clean finished"
test:
	@echo  "[DIONE] test started"
	-bin/$(PROJECT) $(FILE)
	@echo "[DIONE] test finished"
