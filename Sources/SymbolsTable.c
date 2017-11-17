#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SymbolsTable.h"
#include "InstructionsList.h"

extern unsigned long long labelCounter;
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

Symbol symbolsTableAddSymbolBis(Symbol n, char* c){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		strncpy(result->id,c,BUFFER_SIZE);
		snprintf(result->mipsId,BUFFER_SIZE,"var_%llu",variableCounter++);
		snprintf(temp,BUFFER_SIZE,"%s: .word 0",result->mipsId);
		instructionPushBack(rootTree,temp,1);
		result->init = false;
		result->constante = false;
		result->creationLabelCounter = labelCounter;
		result->next = NULL;
		return result;
	}else {
		if(strcmp(n->id,c))
			n->next = symbolsTableAddSymbolBis(n->next, c);
		return n;
	}
}

Symbol symbolsTableAddSymbol(SymbolsTable l, char* c){
	*l = symbolsTableAddSymbolBis(*l,c);
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
		result->value_constante = i;
		result->creationLabelCounter = labelCounter;
		result->next = NULL;
		return result;
	}else {
		if(strcmp(n->id,c))
			n->next = symbolsTableAddSymbolConstBis(n->next, c, i);
		return n;
	}
}

Symbol symbolsTableAddSymbolConst(SymbolsTable l, char* c, int i){
	*l = symbolsTableAddSymbolConstBis(*l,c,i);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableGetSymbolByIdBis(Symbol n, char* c){
	if(n == NULL) return NULL;
	if(!strcmp(n->id,c)) return n;
	return symbolsTableGetSymbolByIdBis(n->next,c);
}

Symbol symbolsTableGetSymbolById(SymbolsTable l, char* c){
	return symbolsTableGetSymbolByIdBis(*l, c);
}

Symbol symbolsTableRemoveSymbolBis(Symbol n, char* c){
	if(n == NULL) return NULL;
	if(!strcmp(n->id,c)){
		Symbol tmp = n->next;
		free(n);
		return tmp;
	}else{
		n->next = symbolsTableRemoveSymbolBis(n->next,c);
		return n;
	}
}

void symbolsTableRemoveSymbol(SymbolsTable l, char* c){
	*l = symbolsTableRemoveSymbolBis(*l, c);
}

Symbol symbolsTableRemoveAllSymbolGreaterThanBis(Symbol n,unsigned int i){
	if(n == NULL) return NULL;
	n->next = symbolsTableRemoveAllSymbolGreaterThanBis(n->next,i);
	if(n->creationLabelCounter >= i){
		Symbol tmp = n->next;
		free(n);
		return tmp;
	}else{
		return n;
	}
}

void symbolsTableRemoveAllSymbolGreaterThan(SymbolsTable l, int i){
	*l = symbolsTableRemoveAllSymbolGreaterThanBis(*l, i); 
}