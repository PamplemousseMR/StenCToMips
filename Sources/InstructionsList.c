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
}

void instrucitonFree(InstructionsList i)
{
	if((*i)->next != NULL)
	{
		instrucitonFree(&((*i)->next));
	}
	free((*i));
}

void instructionPushBack(InstructionsList i, char* c, int ind)
{
	Instruction end = (*i);
	while(end->next != NULL)
	{
		end = end->next; 
	}

	Instruction newI = instructionMalloc(c, ind);
	end->next = newI;
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
	while(end->next != NULL)
	{
		end = end->next; 
	}
	end->next = (*i2);
}

void instructionIncr(InstructionsList i, int ind)
{
	if((*i)->next != NULL)
	{
		instructionIncr(&((*i)->next),ind);
	}
	(*i)->indentation += ind;
}

/*static void instructionPrint(InstructionsList i)
{
	printf("ins : %s %d\n",(*i)->code,(*i)->indentation);
	if((*i)->next != NULL)
	{
		instructionPrint(&((*i)->next));
	}
}

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

	instrucitonFree(list);
	instrucitonFree(list2);

	return EXIT_SUCCESS;
}*/