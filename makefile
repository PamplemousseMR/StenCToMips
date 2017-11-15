EXEC = YACCFOREVER.prog
SRCDIR = Sources
BUILD = Build
OBJS = $(BUILD)/y.tab.c $(BUILD)/lex.yy.c $(BUILD)/SymbolesTable.o $(BUILD)/InstructionsList.o

$(EXEC) : $(OBJS)
	gcc $^ -ly -ll -o $@ -I Sources/

$(BUILD)/y.tab.c : $(SRCDIR)/SyntaxParser.y
	yacc -d $< -o $@

$(BUILD)/lex.yy.c : $(SRCDIR)/LexicalParser.lex
	lex -o $@ $<

$(BUILD)/SymbolesTable.o : $(SRCDIR)/SymbolesTable.c $(SRCDIR)/SymbolesTable.h
	gcc -c -Wall -Wextra -o $@ $< 

$(BUILD)/InstructionsList.o : $(SRCDIR)/InstructionsList.c $(SRCDIR)/InstructionsList.h
	gcc -c -Wall -Wextra -o $@ $< 

clean :
	rm $(EXEC) $(BUILD)/* output.mips
	
