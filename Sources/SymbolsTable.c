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
	memset(*l, 0, sizeof(struct s_symbol*));
	**l = NULL;
}

void symbolsTableFreeBis(Symbol n){
	if(n != NULL){
		symbolsTableFreeBis(n->next);
		n->next = NULL;
		if(n->data != NULL){
			if(n->type == function){
				instructionListFree(((Function*)n->data)->stackInstructions);
				((Function*)n->data)->stackInstructions = NULL;
				instructionListFree(((Function*)n->data)->unStackInstructions);
				((Function*)n->data)->unStackInstructions = NULL;
				symbolsTableFree(((Function*)n->data)->argumentsTable);
				((Function*)n->data)->argumentsTable = NULL;
			}
			free(n->data);
			n->data = NULL;
		}
		free(n);
		n = NULL;
	}
}

void symbolsTableFree(SymbolsTable l){
	symbolsTableFreeBis(*l);
	*l = NULL;
	free(l);
	l = NULL;
}

Symbol symbolsTableAddSymbolUnitBis(Symbol n, char* c, bool init){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		memset(result, 0, sizeof(struct s_symbol));
		Unit* data = (Unit*)malloc(sizeof(Unit));
		memset(data, 0, sizeof(Unit));
		strncpy(data->id,c,BUFFER_SIZE);
		snprintf(data->mipsId,BUFFER_SIZE,"var_%llu_Unit",variableCounter++);
		snprintf(temp,BUFFER_SIZE,"%s: .word 0    # -> %s",data->mipsId,c);
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

Symbol symbolsTableAddSymbolDefineBis(Symbol n, char* c, int i){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		memset(result, 0, sizeof(struct s_symbol));
		ConstUnit* data = (ConstUnit*)malloc(sizeof(ConstUnit));
		memset(data, 0, sizeof(ConstUnit));
		strncpy(data->id,c,BUFFER_SIZE);
		data->value = i;
		result->type = constUnit;
		result->data = (void*)data;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddSymbolDefineBis(n->next, c, i);
		return n;
	}
}

Symbol symbolsTableAddSymbolDefine(SymbolsTable l, char* c, int i){
	*l = symbolsTableAddSymbolDefineBis(*l,c,i);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableAddArrayBis(Symbol n, char* c){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		memset(result, 0, sizeof(struct s_symbol));
		Array* data = (Array*)malloc(sizeof(Array));
		memset(data, 0, sizeof(Array));
		strncpy(data->id,c,BUFFER_SIZE);
		snprintf(data->mipsId,BUFFER_SIZE,"var_%llu_Array",variableCounter++);
		snprintf(temp,BUFFER_SIZE,"%s: .word 0    # -> %s",data->mipsId,c);
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

Symbol symbolsTableAddStencilBis(Symbol n, char* c){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		memset(result, 0, sizeof(struct s_symbol));
		Stencil* data = (Stencil*)malloc(sizeof(Stencil));
		memset(data, 0, sizeof(Stencil));
		strncpy(data->id,c,BUFFER_SIZE);
		snprintf(data->mipsId,BUFFER_SIZE,"var_%llu_Stencil",variableCounter++);
		snprintf(temp,BUFFER_SIZE,"%s: .word 0    # -> %s",data->mipsId,c);
		instructionPushBack(rootTree,temp,1);
		data->nbNeighbour = 0;
		data->nbDimension = 0;
		data->constEval = false;
		data->constant = false;
		data->stepsToAcces = NULL;
		result->type = stencil;
		result->data = (void*)data;
		result->next = NULL;
		return result;
	}else {
		n->next = symbolsTableAddStencilBis(n->next, c);
		return n;
	}
}

Symbol symbolsTableAddStencil(SymbolsTable l, char* c){
	*l = symbolsTableAddStencilBis(*l, c);
	return symbolsTableGetSymbolById(l,c);
}

Symbol symbolsTableAddFunctionBis(Symbol n, char* c){
	if(n == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		memset(result, 0, sizeof(struct s_symbol));
		Function* data = (Function*)malloc(sizeof(Function));
		memset(data, 0, sizeof(Function));
		strncpy(data->id,c,BUFFER_SIZE);
		if(!strcmp(c,"main")){
			snprintf(data->mipsId,BUFFER_SIZE,"FUN_MAIN");
			mainFound = true;
		}else{ 
			snprintf(data->mipsId,BUFFER_SIZE,"FUN_%llu",variableCounter++);
		}			
		data->nbArgs = 0;
		instructionListMalloc(&data->stackInstructions);
		instructionListMalloc(&data->unStackInstructions);
		symbolsTableMalloc(&data->argumentsTable);
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
		memset(result, 0, sizeof(struct s_symbol));
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
		case stencil :
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

Symbol symbolsTableAddSymboleAlreadyExistBis(Symbol s, Symbol s2){
	if(s == NULL){
		Symbol result = (Symbol)malloc(sizeof(struct s_symbol));
		memset(result, 0, sizeof(struct s_symbol));
		result->type = s2->type;
		void * data;
		switch(s2->type){
			case unit :
				data = (Unit*)malloc(sizeof(Unit));
				memcpy(data,s2->data,sizeof(Unit));
				break;
			case array :
				data = (Array*)malloc(sizeof(Array));
				memcpy(data,s2->data,sizeof(Array));
				break;
			case stencil :
				data = (Stencil*)malloc(sizeof(Stencil));
				memcpy(data,s2->data,sizeof(Stencil));
				break;
			default :
				return NULL;
		}
		result->data = data;
		return result;
	}else{
		s->next = symbolsTableAddSymboleAlreadyExistBis(s->next,s2);
		return s;	
	}
}

void symbolsTableAddSymboleAlreadyExist(SymbolsTable s, Symbol s2){
	*s = symbolsTableAddSymboleAlreadyExistBis(*s, s2);
}

Symbol getSymbolByIdxBis(Symbol s, int i){
	if(i == 0 || s == NULL) return s;
	return getSymbolByIdxBis(s->next,i-1);
}

Symbol getSymbolByIdx(SymbolsTable s, int i){
	if(i < 0) return NULL;
	return getSymbolByIdxBis(*s,i);
}