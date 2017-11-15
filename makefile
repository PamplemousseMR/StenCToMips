EXEC = YACCFOREVER.prog
SRCDIR = Sources
BUILD = Build
OBJS = $(BUILD)/SyntaxParser.o $(BUILD)/LexicalParser.o $(BUILD)/SymbolesTable.o $(BUILD)/InstructionsList.o
GCC = gcc -Wall -Wextra -I Sources/

$(EXEC) : $(OBJS)
	gcc $^ -ly -ll -o $@ 

$(BUILD)/SyntaxParser.o : $(SRCDIR)/SyntaxParser.y
	yacc -d $< -o $(BUILD)/SyntaxParser.c
	$(GCC) -c -o $@ $(BUILD)/SyntaxParser.c

$(BUILD)/LexicalParser.o : $(SRCDIR)/LexicalParser.lex
	lex -o $(BUILD)/LexicalParser.c $<
	$(GCC) -c -o $@ $(BUILD)/LexicalParser.c

$(BUILD)/SymbolesTable.o : $(SRCDIR)/SymbolesTable.c $(SRCDIR)/SymbolesTable.h
	$(GCC) -c -o $@ $< 

$(BUILD)/InstructionsList.o : $(SRCDIR)/InstructionsList.c $(SRCDIR)/InstructionsList.h
	$(GCC) -c -o $@ $< 

clean :
	rm $(EXEC) $(BUILD)/* output.mips
	
