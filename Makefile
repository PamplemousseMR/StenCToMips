EXEC = stenctomips
SRCDIR = Sources
CCFORCEDFLAGS = -I Sources/ -c -o
CCFLAGS = -O3
BUILD = Build
OBJS = $(BUILD)/SyntaxParser.o $(BUILD)/LexicalParser.o $(BUILD)/SymbolsTable.o $(BUILD)/InstructionsList.o
OUTPUT = output.mips

$(EXEC) : $(BUILD) $(OBJS)
	$(CC) $(CCFLAGS) $(OBJS) -ly -ll -o $@ 

$(BUILD)/SyntaxParser.o : $(SRCDIR)/SyntaxParser.y
	yacc -d $< -o $(BUILD)/SyntaxParser.c
	$(CC) $(CCFLAGS) $(CCFORCEDFLAGS) $@ $(BUILD)/SyntaxParser.c

$(BUILD)/LexicalParser.o : $(SRCDIR)/LexicalParser.lex
	lex -o $(BUILD)/LexicalParser.c $<
	$(CC) $(CCFLAGS) $(CCFORCEDFLAGS) $@ $(BUILD)/LexicalParser.c

$(BUILD)/SymbolsTable.o : $(SRCDIR)/SymbolsTable.c $(SRCDIR)/SymbolsTable.h
	$(CC) $(CCFLAGS) $(CCFORCEDFLAGS)$@ $< 

$(BUILD)/InstructionsList.o : $(SRCDIR)/InstructionsList.c $(SRCDIR)/InstructionsList.h
	$(CC) $(CCFLAGS) $(CCFORCEDFLAGS)$@ $< 

$(BUILD) :
	mkdir $(BUILD)

debug: CCFLAGS = -DDEBUG -Wall -Wextra
debug: $(EXEC)

clean :
	rm -r -f  $(EXEC) $(BUILD) $(OUTPUT)
