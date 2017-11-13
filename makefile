EXEC = YACCFOREVER.prog
SRCDIR = Sources
BUILD = Build
OBJS = $(BUILD)/y.tab.c $(BUILD)/lex.yy.c $(BUILD)/SymbolesTable.o 

$(EXEC) : $(OBJS)
	gcc $^ -ly -ll -o $@ -I Sources/

$(BUILD)/y.tab.c : $(SRCDIR)/SyntaxParser.y
	yacc -d $< -o $@

$(BUILD)/lex.yy.c : $(SRCDIR)/LexicalParser.lex
	lex -o $@ $<

$(BUILD)/SymbolesTable.o : $(SRCDIR)/SymbolesTable.c $(SRCDIR)/SymbolesTable.h
	gcc -c -Wall -Wextra -o $@ $< 
	
debug : $(BUILD)/y.tab.c
	lex -D_DEBUG -o $(BUILD)/lex.yy.c $(SRCDIR)/LexicalParser.lex
	gcc -Wall -Wextra $(BUILD)/y.tab.c $(BUILD)/lex.yy.c -ly -ll -o $(EXEC) -I Sources/

clean :
	rm $(EXEC) $(BUILD)/* output.mips
	
