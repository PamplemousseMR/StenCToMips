EXEC = YACCFOREVER.prog
SRCDIR = Sources
BUILD = Build
OBJS = $(BUILD)/y.tab.c $(BUILD)/lex.yy.c

$(EXEC) : $(OBJS)
	gcc $(BUILD)/y.tab.c $(BUILD)/lex.yy.c -ly -ll -o $(EXEC)

$(BUILD)/y.tab.c : $(SRCDIR)/SyntaxParser.y
	yacc -d $(SRCDIR)/SyntaxParser.y -o $(BUILD)/y.tab.c

$(BUILD)/lex.yy.c : $(SRCDIR)/LexicalParser.lex
	lex -o $(BUILD)/lex.yy.c $(SRCDIR)/LexicalParser.lex

clean :
	rm $(EXEC) $(BUILD)/*
	
