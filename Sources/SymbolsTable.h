#ifndef __SYMBOLESTABLE_H
#define __SYMBOLESTABLE_H

#include "InstructionsList.h"

#define BUFFER_SIZE 50

typedef enum bool{false,true} bool;
typedef enum Type{unit,constUnit,step,array,stencil,function} Type;

typedef struct {
	char id[BUFFER_SIZE];
	char mipsId[BUFFER_SIZE];
	bool init;
}Unit;

typedef struct {
	char id[BUFFER_SIZE];
	int value;
}ConstUnit;

typedef struct {
	char id[BUFFER_SIZE];
	char mipsId[BUFFER_SIZE];
	int nbDimension;
	InstructionsList stepsToAcces;
}Array;

typedef struct {
	char id[BUFFER_SIZE];
	char mipsId[BUFFER_SIZE];
	int nbArgs;
	int numOfFirstArg;
	InstructionsList stackInstructions;
	InstructionsList unStackInstructions;
}Function;

typedef struct s_symbol{
	Type type; 
	void* data;
	struct s_symbol* next;
}*Symbol;

typedef Symbol* SymbolsTable;

void symbolsTableMalloc(SymbolsTable*);
void symbolsTableFree(SymbolsTable);

Symbol symbolsTableAddSymbolUnit(SymbolsTable, char*, bool);
Symbol symbolsTableAddSymbolConstUnit(SymbolsTable, char*, int);
Symbol symbolsTableAddArray(SymbolsTable, char*);
Symbol symbolsTableAddFunction(SymbolsTable, char*);
void symbolsTableAddStep(SymbolsTable);
Symbol symbolsTableGetSymbolById(SymbolsTable, char*);
void symbolsTableRemoveUntilStep(SymbolsTable);

#endif