#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SymbolsTable.h"
#include "InstructionsList.h"

extern unsigned long long variableCounter;
extern InstructionsList rootTree;
char temp[BUFFER_SIZE];
extern int mainFound;

void symbolsTableMalloc(SymbolsTable* l){
	*l = (SymbolsTable)malloc(sizeof(struct s_symbol*));
	**l = NULL;
}

void symbolsTableFreeBis(Symbol n){
	if(n != NULL){
		symbolsTableFreeBis(n->next);
		if(n->data != NULL){
			if(n->type == function){
				instructionListFree(((Function*)n->data)->stackInstructions);
				instructionListFree(((Function*)n->data)->unStackInstructions);
			}
			free(n->data);
		}
		free(n);
	}
}

void symbolsTableFree(SymbolsTable l){
	symbolsTableFreeBis(*l);
	free(l);
	l = NULL;
}

Symbol symbolsTableAddSymbolUnitBis(Symbol n, char* c, bool init){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		Unit* data = (Unit*)malloc(sizeof(Unit));
		strncpy(data->id,c,BUFFER_SIZE);
		snprintf(data->mipsId,BUFFER_SIZE,"var_%llu_Unit",variableCounter++);
		snprintf(temp,BUFFER_SIZE,"%s: .word 0",data->mipsId);
		instructionPushBack(rootTree,temp,1);
		data->init = init;
		result->type = unit;
		result->data = (void*)data;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddSymbolUnitBis(n->next, c, init);
		return n;
	}
}

Symbol symbolsTableAddSymbolUnit(SymbolsTable l, char* c, bool init){
	*l = symbolsTableAddSymbolUnitBis(*l, c, init);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableAddSymbolConstUnitBis(Symbol n, char* c, int i){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		ConstUnit* data = (ConstUnit*)malloc(sizeof(ConstUnit));
		strncpy(data->id,c,BUFFER_SIZE);
		instructionPushBack(rootTree,temp,1);
		data->value = i;
		result->type = constUnit;
		result->data = (void*)data;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddSymbolConstUnitBis(n->next, c, i);
		return n;
	}
}

Symbol symbolsTableAddSymbolConstUnit(SymbolsTable l, char* c, int i){
	*l = symbolsTableAddSymbolConstUnitBis(*l,c,i);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableAddArrayBis(Symbol n, char* c){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		Array* data = (Array*)malloc(sizeof(Array));
		strncpy(data->id,c,BUFFER_SIZE);
		snprintf(data->mipsId,BUFFER_SIZE,"var_%llu_Array",variableCounter++);
		snprintf(temp,BUFFER_SIZE,"%s: .word 0",data->mipsId);
		instructionPushBack(rootTree,temp,1);
		data->nbDimension = 0;
		data->stepsToAcces = NULL;
		data->constant = false;
		result->type = array;
		result->data = (void*)data;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddArrayBis(n->next, c);
		return n;
	}
}

Symbol symbolsTableAddArray(SymbolsTable l, char* c){
	*l = symbolsTableAddArrayBis(*l, c);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableAddFunctionBis(Symbol n, char* c){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		Function* data = (Function*)malloc(sizeof(Function));
		strncpy(data->id,c,BUFFER_SIZE);
		if(!strcmp(c,"main")){
			snprintf(data->mipsId,BUFFER_SIZE,"FUN_MAIN");
			mainFound = true;
		}else{ 
			snprintf(data->mipsId,BUFFER_SIZE,"FUN_%llu",variableCounter++);
		}			
		data->nbArgs = 0;
		data->numOfFirstArg = variableCounter;
		instructionListMalloc(&data->stackInstructions);
		instructionListMalloc(&data->unStackInstructions);
		result->type = function;
		result->data = (void*)data;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddFunctionBis(n->next, c);
		return n;
	}	
}

Symbol symbolsTableAddFunction(SymbolsTable l, char* c){
	*l = symbolsTableAddFunctionBis(*l, c);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableAddStepBis(Symbol n){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		result->type = step;
		result->next = NULL;
		result->data = NULL;
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
	switch(n->type){
		case unit :
		case constUnit :
		case array :
		case function : 
			if(!strcmp(((Unit*)n->data)->id,c)) return n;
			break;
		case step:
			break;
		default :
			printf("TODO symbolsTableGetSymbolByIdBis");
			break;
	}
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
		if(n->type == step){
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