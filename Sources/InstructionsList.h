#ifndef __INSTRUCTIONSLISTE_H
#define __INSTRUCTIONSLISTE_H

#include <stdio.h>

#define INSTRUCTION_SIZE 100 

typedef struct s_instruction
{
	char code[INSTRUCTION_SIZE];
	int indentation;
	struct s_instruction* next;
} *Instruction;

typedef Instruction* InstructionsList;

void instructionListMalloc(InstructionsList*);
void instructionListFree(InstructionsList);
void instructionRealloc(InstructionsList*);

void instructionPushBack(InstructionsList, char*, int);
void instructionPushForward(InstructionsList, char*, int);
void instructionConcat(InstructionsList, InstructionsList); //1met B a la suite de A (A->next....->next = B)
void instructionIncr(InstructionsList, int);	//incrémente de n tout les nbIndentation de la liste

void instructionListPrintFILE(InstructionsList,FILE*);

void instructionEmpilerDepilerS4S5(InstructionsList);
#endif