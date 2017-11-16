#ifndef __INSTRUCTIONSLISTE_H
#define __INSTRUCTIONSLISTE_H

#include <stdio.h>

#define BUFFER_SIZE 50 

typedef struct s_instruction
{
	char code[BUFFER_SIZE];
	int indentation;
	struct s_instruction* next;
} *Instruction;

typedef Instruction* InstructionsList;

Instruction instructionMalloc(char*, int);
void instructionFree(InstructionsList);

void instructionPushBack(InstructionsList, char*, int);
void instructionPushForward(InstructionsList, char*, int);
void instructionConcat(InstructionsList, InstructionsList); //1met B a la suite de A (A->next....->next = B)
void instructionIncr(InstructionsList, int);	//incrémente de n tout les nbIndentation de la liste

void instructionPrintFILE(InstructionsList,FILE *);

//tempo de test!
void instructionListMalloc(InstructionsList*);
void instructionListFree(InstructionsList);
#endif