#ifndef __SYMBOLESTABLE_H
#define __SYMBOLESTABLE_H

#define BUFFER_SIZE 50


typedef enum bool{false,true} bool;

typedef struct s_symbol{
	char id[BUFFER_SIZE];
	char mipsId[BUFFER_SIZE];
	bool init;
	bool constante;
	bool step;
	struct s_symbol* next;
}*Symbol;

typedef Symbol* SymbolsTable;

void symbolsTableMalloc(SymbolsTable*);
void symbolsTableFree(SymbolsTable);

Symbol symbolsTableAddSymbol(SymbolsTable, char*, bool);
Symbol symbolsTableAddSymbolConst(SymbolsTable, char*, int);
void symbolsTableAddStep(SymbolsTable);
Symbol symbolsTableGetSymbolById(SymbolsTable, char*);
void symbolsTableRemoveUntilStep(SymbolsTable);

#endif