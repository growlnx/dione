.PHONY: clean build test

PROJECT	= dione
CC		= clang++
CFLAGS	= -g -std=c++17
LFLAGS	= -ldl
BFLAGS  = -v
FFLAGS  =
SRC		= src
OBJ		= obj
DEST	= bin

all: 	clean build

build:
	@echo "[DIONE] build started"
	bison $(BFLAGS) -o $(SRC)/parser.cc $(SRC)/parser.yy 
		
	flex  $(FFLAGS) -o $(SRC)/lexer.cc $(SRC)/lexer.ll
	
	mkdir -p $(DEST) $(OBJ)

	$(CC) -o $(OBJ)/driver.o     		-c $(SRC)/driver.cc 			$(CFLAGS)
	$(CC) -o $(OBJ)/parser.o     		-c $(SRC)/parser.cc 			$(CFLAGS)
	$(CC) -o $(OBJ)/dione_ast.o   		-c $(SRC)/dione_ast.cc 			$(CFLAGS)
	$(CC) -o $(OBJ)/object_ast.o   		-c $(SRC)/object_ast.cc 		$(CFLAGS)
	$(CC) -o $(OBJ)/expression_ast.o   	-c $(SRC)/expression_ast.cc     $(CFLAGS)
	$(CC) -o $(OBJ)/lexer.o      		-c $(SRC)/lexer.cc 				$(CFLAGS)
	$(CC) -o $(OBJ)/$(PROJECT).o 		-c $(SRC)/$(PROJECT).cc 		$(CFLAGS)
	$(CC) -o $(OBJ)/cli.o        		-c $(SRC)/cli.cc 				$(CFLAGS)
	
	$(CC) -o $(DEST)/$(PROJECT) $(CFLAGS) $(LFLAGS) $(OBJ)/*.o
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
