EXEC = YACCFOREVER.prog
SRCDIR = Sources
CCFORCEDFLAGS = -I Sources/ -c -o
CCFLAGS = -O3
BUILD = Build
OBJS = $(BUILD)/SyntaxParser.o $(BUILD)/LexicalParser.o $(BUILD)/SymbolesTable.o $(BUILD)/InstructionsList.o
GCC = gcc 

$(EXEC) : $(OBJS)
	gcc $^ -ly -ll -o $@ 

$(BUILD)/SyntaxParser.o : $(SRCDIR)/SyntaxParser.y
	yacc -d $< -o $(BUILD)/SyntaxParser.c
	$(GCC) $(CCFLAGS) $(CCFORCEDFLAGS) $@ $(BUILD)/SyntaxParser.c

$(BUILD)/LexicalParser.o : $(SRCDIR)/LexicalParser.lex
	lex -o $(BUILD)/LexicalParser.c $<
	$(GCC) $(CCFLAGS) $(CCFORCEDFLAGS) $@ $(BUILD)/LexicalParser.c

$(BUILD)/SymbolesTable.o : $(SRCDIR)/SymbolesTable.c $(SRCDIR)/SymbolesTable.h
	$(GCC) $(CCFLAGS) $(CCFORCEDFLAGS)$@ $< 

$(BUILD)/InstructionsList.o : $(SRCDIR)/InstructionsList.c $(SRCDIR)/InstructionsList.h
	$(GCC) $(CCFLAGS) $(CCFORCEDFLAGS)$@ $< 

debug: CCFLAGS = -DDEBUG -Wall -Wextra
debug: $(EXEC)

clean :
	rm $(EXEC) $(BUILD)/* output.mips
	
