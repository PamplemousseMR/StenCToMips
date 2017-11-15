#ifndef __INSTRUCTIONSSERIE_H
#define __INSTRUCTIONSSERIE_H

#define BUFFER_SIZE 50 

typedef struct s_instruction
{
	char code[BUFFER_SIZE];
	int indentation;
	struct s_instruction* next;
} *Instruction;

typedef Instruction* InstructionList;

Instruction instructionMalloc(char*, int);
void instrucitonFree(InstructionList);

void instructionPushBack(InstructionList, char*, int);
void instructionPushForward(InstructionList, char*, int);
void instructionConcat(InstructionList, InstructionList); //1met B a la suite de A (A->next....->next = B)
void instructionIncr(InstructionList, int);	//incrémente de n tout les nbIndentation de la liste

#endif