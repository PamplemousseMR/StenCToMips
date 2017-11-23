#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "InstructionsList.h"

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
	}
}

void instructionListMalloc(InstructionsList* i){
	*i = (InstructionsList)malloc(sizeof(struct s_instruction**));
	**i = NULL;
}

void instructionListFree(InstructionsList i){
	instructionFree(i);
	free(i);
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
}

void instructionIncr(InstructionsList i, int ind)
{
	if((*i) != NULL)
	{
		(*i)->indentation += ind;
		instructionIncr(&((*i)->next),ind);
	}	
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

void instructionEmpilerDepilerS4S5(InstructionsList l){
	instructionPushForward(l,"sw $s5 4($sp)",1);
	instructionPushForward(l,"sw $s4 0($sp)",1);
	instructionPushForward(l,"subi $sp $sp 8",1);
	instructionPushBack(l,"lw $s4 0($sp)",1);
	instructionPushBack(l,"lw $s5 4($sp)",1);
	instructionPushBack(l,"addi $sp $sp 8",1);
}