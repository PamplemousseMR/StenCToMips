#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "InstructionsList.h"

Instruction instructionMalloc(char* c, int ind)
{
	Instruction i = (Instruction)malloc(sizeof(struct s_instruction));
	strncpy(i->code,c,BUFFER_SIZE);
	i->indentation = ind;
	i->next = NULL;
	return i;
}

void instructionFree(InstructionsList i)
{
	if((*i) != NULL)
	{
		instructionFree(&((*i)->next));
		free((*i));
	}
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
}

void instructionIncr(InstructionsList i, int ind)
{
	if((*i) != NULL)
	{
		(*i)->indentation += ind;
		instructionIncr(&((*i)->next),ind);
	}	
}

void instructionPrint(InstructionsList i)
{
	int ind;
	if((*i) != NULL)
	{
		printf("ins : ");
		// printf("ins : %s %d\n",(*i)->code,(*i)->indentation);
		for(ind = (*i)->indentation;ind > 0; ind--)
			printf("\t");
		printf("%s\n",(*i)->code);
		instructionPrint(&((*i)->next));
	}
}

void instructionListMalloc(InstructionsList* i){
	*i = (InstructionsList)malloc(sizeof(struct s_instruction**));
	**i = NULL;
}

void instructionListFree(InstructionsList i){
	free(i);
}

/*
int main()
{
	Instruction root = instructionMalloc("first", 0);
	InstructionsList list = &root;

	instructionPrint(list);
	printf("\n");

	instructionPushBack(list,"second",1);
	instructionPrint(list);
	printf("\n");

	instructionPushBack(list,"third",1);
	instructionPrint(list);
	printf("\n");

	instructionPushBack(list,"quad",3);
	instructionPrint(list);
	printf("\n");

	instructionPushForward(list,"realFirst",2);
	instructionPrint(list);
	printf("\n");

	Instruction root2 = instructionMalloc("first2", 0);
	InstructionsList list2 = &root2;

	instructionPushBack(list2,"second2",1);
	instructionPushBack(list2,"third2",1);
	instructionPushBack(list2,"quad2",3);

	instructionConcat(list,list2);
	instructionPrint(list);
	printf("\n");

	instructionIncr(list2,5);
	instructionPrint(list);
	printf("\n");

	instructionFree(list);
	instructionFree(list2);

	return EXIT_SUCCESS;
}*/