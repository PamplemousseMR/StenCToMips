#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "InstructionsList.h"
#include "SymbolsTable.h"
extern unsigned long long labelCounter;

static inline Instruction instructionMalloc(char* c, int ind)
{
	Instruction i = (Instruction)malloc(sizeof(struct s_instruction));
	strncpy(i->code,c,INSTRUCTION_SIZE);
	i->indentation = ind;
	i->next = NULL;

	return i;
}

static inline void instructionFree(InstructionsList i)
{
	if((*i) != NULL)
	{
		instructionFree(&((*i)->next));
		free(*i);
		*i = NULL;
	}
}

void instructionListMalloc(InstructionsList* i){
	*i = (InstructionsList)malloc(sizeof(struct s_instruction**));
	**i = NULL;
}

void instructionListFree(InstructionsList i){
	instructionFree(i);
	free(i);
	i = NULL;
}

void instructionReAlloc(InstructionsList* i){
	instructionListFree(*i);
	instructionListMalloc(i);
}

void instructionPushBack(InstructionsList i, char* c, int ind)
{	
	Instruction newI = instructionMalloc(c, ind);
	Instruction end = (*i);
	if(end == NULL){
		(*i) = newI;
	}else{
		while(end->next != NULL)
		{
			end = end->next; 
		}

		end->next = newI;
	}
}

void instructionPushForward(InstructionsList i, char* c, int ind)
{
	Instruction newI = instructionMalloc(c, ind);
	newI->next = (*i);
	(*i) = newI;
}

void instructionConcat(InstructionsList i1, InstructionsList i2)
{
	
	Instruction end = (*i1);
	if(end == NULL){
		(*i1) = (*i2);
	}else{
		while(end->next != NULL)
		{
			end = end->next; 
		}

		end->next = (*i2);
	}
	free(i2);
	i2 = NULL;
}

void instructionIncr(InstructionsList i, int ind)
{
	if((*i) != NULL)
	{
		(*i)->indentation += ind;
		instructionIncr(&((*i)->next),ind);
	}	
}

void instructionCopy(InstructionsList dest, InstructionsList source){
	InstructionsList listeTemp;
	Instruction temp = (*source);
	
	instructionListMalloc(&listeTemp);
	while(temp != NULL){
		instructionPushBack(listeTemp,temp->code,temp->indentation);
		temp = temp->next;
	}
	instructionConcat(dest,listeTemp);
}

void instructionListPrintFILE(InstructionsList i,FILE * f)
{
	int ind;
	if((*i) != NULL)
	{
		// printf("ins : %s %d\n",(*i)->code,(*i)->indentation);
		for(ind = (*i)->indentation;ind > 0; ind--)
			fprintf(f,"\t");
		fprintf(f,"%s\n",(*i)->code);
		instructionListPrintFILE(&((*i)->next),f);
	}
}

InstructionsList instructionStackUnstackS4S5S6S7T8(InstructionsList l,void * s){
	char tmp[INSTRUCTION_SIZE];
	InstructionsList result;
	instructionListMalloc(&result);
	
	Symbol s2 = s;
	Array* arr = (Array*)s2->data;
	Stencil* sten = (Stencil*)s2->data;
	//enregistrement du tableau d'acces
	
	//recupère la taille du tableau d'acces du symbole s à stocker 
	if(s2->type == array){
		snprintf(tmp,INSTRUCTION_SIZE,"li $t1 %d",arr->nbDimension);
		instructionPushBack(result,tmp,1);
		snprintf(tmp,INSTRUCTION_SIZE,"la $t2 %s_accesTable",arr->mipsId);
		instructionPushBack(result,tmp,1);
	} else {
		snprintf(tmp,INSTRUCTION_SIZE,"lw $t1 %s_nbDimension",sten->mipsId);
		instructionPushBack(result,tmp,1);
		snprintf(tmp,INSTRUCTION_SIZE,"lw $t2 %s_accesTable",sten->mipsId);
		instructionPushBack(result,tmp,1);
	}
	instructionPushBack(result,"sll $t1 $t1 2",1);
	instructionPushBack(result,"add $t1 $t1 $t2",1);
	instructionPushBack(result,"sub $t1 $t1 4",1); 		//$t0 = adresse du dernier du tableau
	snprintf(tmp,INSTRUCTION_SIZE,"STACK_LOOP_%llu_START :",labelCounter);
	instructionPushBack(result,tmp,1);
	snprintf(tmp,INSTRUCTION_SIZE,"blt $t1 $t2 STACK_LOOP_%llu_END",labelCounter);
	instructionPushBack(result,tmp,1);
		instructionPushBack(result,"lw $t3 ($t1)",1);
		
		instructionPushBack(result,"sub $sp $sp 4",1);
		instructionPushBack(result,"sw $t3 0($sp)",1);
		
		instructionPushBack(result,"sub $t1 $t1 4",1);
		snprintf(tmp,INSTRUCTION_SIZE,"j STACK_LOOP_%llu_START",labelCounter);
		instructionPushBack(result,tmp,1);
	snprintf(tmp,INSTRUCTION_SIZE,"STACK_LOOP_%llu_END :",labelCounter);
	instructionPushBack(result,tmp,1);
	labelCounter++;
	
	//enregistrement des registres
	instructionPushBack(result,"sub $sp $sp 20",1);
	instructionPushBack(result,"sw $s4 0($sp)",1);
	instructionPushBack(result,"sw $s5 4($sp)",1);
	instructionPushBack(result,"sw $s6 8($sp)",1);
	instructionPushBack(result,"sw $s7 12($sp)",1);
	instructionPushBack(result,"sw $t8 16($sp)",1);
	
	//<============L==============================
	instructionConcat(result,l);
	//<============L==============================

	//restitution des registres
	instructionPushBack(result,"lw $s4 0($sp)",1);
	instructionPushBack(result,"lw $s5 4($sp)",1);
	instructionPushBack(result,"lw $s6 8($sp)",1);
	instructionPushBack(result,"lw $s7 12($sp)",1);
	instructionPushBack(result,"lw $t8 16($sp)",1);
	instructionPushBack(result,"add $sp $sp 20",1);
	
	//restitution du tableau d'acces
	
	//recupère la taille du tableau d'acces du symbole s à stocker 
	if(s2->type == array){
		snprintf(tmp,INSTRUCTION_SIZE,"li $t2 %d",arr->nbDimension);
		instructionPushBack(result,tmp,1);
		snprintf(tmp,INSTRUCTION_SIZE,"la $t1 %s_accesTable",arr->mipsId);
		instructionPushBack(result,tmp,1);
	} else {
		snprintf(tmp,INSTRUCTION_SIZE,"lw $t2 %s_nbDimension",sten->mipsId);
		instructionPushBack(result,tmp,1);
		snprintf(tmp,INSTRUCTION_SIZE,"lw $t1 %s_accesTable",sten->mipsId);
		instructionPushBack(result,tmp,1);
	}
	
	snprintf(tmp,INSTRUCTION_SIZE,"STACK_LOOP_%llu_START :",labelCounter);
	instructionPushBack(result,tmp,1);
	snprintf(tmp,INSTRUCTION_SIZE,"ble $t2 $0 STACK_LOOP_%llu_END",labelCounter);
	instructionPushBack(result,tmp,1);
		instructionPushBack(result,"lw $t3 0($sp)",1);
		instructionPushBack(result,"add $sp $sp 4",1);
		instructionPushBack(result,"sw $t3 ($t1)",1);
		instructionPushBack(result,"add $t1 $t1 4",1);
		
		instructionPushBack(result,"sub $t2 $t2 1",1);
		snprintf(tmp,INSTRUCTION_SIZE,"j STACK_LOOP_%llu_START",labelCounter);
		instructionPushBack(result,tmp,1);
	snprintf(tmp,INSTRUCTION_SIZE,"STACK_LOOP_%llu_END :",labelCounter);
	instructionPushBack(result,tmp,1);
	labelCounter++;
	
	return result;
}