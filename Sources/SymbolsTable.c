#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SymbolsTable.h"
#include "InstructionsList.h"

extern unsigned long long variableCounter;
extern InstructionsList rootTree;
char temp[BUFFER_SIZE];

void symbolsTableMalloc(SymbolsTable* l){
	*l = (SymbolsTable)malloc(sizeof(struct s_symbol*));
	**l = NULL;
}

void symbolsTableFreeBis(Symbol n){
	if(n != NULL) 
		symbolsTableFreeBis(n->next);
	free(n);
}

void symbolsTableFree(SymbolsTable l){
	symbolsTableFreeBis(*l);
	free(l);
	l = NULL;
}

Symbol symbolsTableAddSymbolBis(Symbol n, char* c, bool init){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		strncpy(result->id,c,BUFFER_SIZE);
		snprintf(result->mipsId,BUFFER_SIZE,"var_%llu",variableCounter++);
		snprintf(temp,BUFFER_SIZE,"%s: .word 0",result->mipsId);
		instructionPushBack(rootTree,temp,1);
		result->init = init;
		result->constante = false;
		result->step = false;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddSymbolBis(n->next, c, init);
		return n;
	}
}

Symbol symbolsTableAddSymbol(SymbolsTable l, char* c, bool init){
	*l = symbolsTableAddSymbolBis(*l, c, init);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableAddSymbolConstBis(Symbol n, char* c, int i){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		strncpy(result->id,c,BUFFER_SIZE);
		snprintf(result->mipsId,BUFFER_SIZE,"var_%llu",variableCounter++);
		snprintf(temp,BUFFER_SIZE,"%s: .word %d",result->mipsId,i);
		instructionPushBack(rootTree,temp,1);
		result->constante = true;
		result->init = true;
		result->step = false;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddSymbolConstBis(n->next, c, i);
		return n;
	}
}

Symbol symbolsTableAddSymbolConst(SymbolsTable l, char* c, int i){
	*l = symbolsTableAddSymbolConstBis(*l,c,i);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableAddStepBis(Symbol n){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		strncpy(result->id,"step",BUFFER_SIZE);
		snprintf(result->mipsId,BUFFER_SIZE,"null");
		result->constante = true;
		result->init = true;
		result->step = true;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddStepBis(n->next);
		return n;
	}
}

void symbolsTableAddStep(SymbolsTable l){
	*l = symbolsTableAddStepBis(*l);
}

Symbol symbolsTableGetSymbolByIdBis(Symbol n, char* c){
	if(n == NULL) return NULL;
	if(!strcmp(n->id,c)) return n;
	return symbolsTableGetSymbolByIdBis(n->next,c);
}

Symbol symbolsTableGetSymbolById(SymbolsTable l, char* c){
	return symbolsTableGetSymbolByIdBis(*l, c);
}

Symbol lastStep = NULL;
static inline void symbolsTableGetLastStep(Symbol n){
	if(n == NULL){
		return;
	} 
	else {
		if(n->step == true){
			lastStep = n;
		}
		symbolsTableGetLastStep(n->next); 
	}
}

Symbol beforeStep = NULL;
static inline bool symbolsTableRemoveStep(Symbol n){
	if(n == NULL){
		return false;
	} 
	else {
		if(n == lastStep){
			if(beforeStep != NULL){
				symbolsTableFreeBis(beforeStep->next);
				beforeStep->next = NULL;
			}else{
				symbolsTableFreeBis(n);
				n = NULL;
			}
			return (beforeStep == NULL);
		}
		beforeStep = n;
		symbolsTableRemoveStep(n->next); 
		return false;
	}
}

void symbolsTableRemoveUntilStep(SymbolsTable l){
	symbolsTableGetLastStep(*l);
	if(lastStep != NULL){
		if(symbolsTableRemoveStep(*l)){
			*l = NULL;
		}
		lastStep = NULL;
		beforeStep = NULL;
	}
}