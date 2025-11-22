SRC = src
INC = include
# Adicionado mechanics.o e ai.o na lista de objetos
OBJ = main.o display.o input.o engine.o mechanics.o ai.o
NASM = nasm -f elf64 -I $(INC)/

all: game

%.o: $(SRC)/%.asm
	 $(NASM) $< -o $@

game: $(OBJ)
	 ld -o game $(OBJ)

clean:
	 rm -f *.o game