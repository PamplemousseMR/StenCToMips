%code requires {
    #include "InstructionsList.h"
}

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "InstructionsList.h"
	#include "SymbolesTable.h"\

	#ifdef DEBUG
	#define printf(args...) printf(args);
	#else
	#define printf(...)
	#endif

	#define PUSH_BACK(dest, indent, code...) snprintf(instructionTempo,BUFFER_SIZE,code);\
													instructionPushBack(dest,instructionTempo,indent)

	#define PUSH_FORWARD(dest, indent, code...) snprintf(instructionTempo,BUFFER_SIZE,code);\
														instructionPushForward(dest,instructionTempo,indent)

	unsigned long long labelCounter = 0;
	unsigned long long variableCounter = 0;

	int yylex();
	void yyerror (char const *s);

	FILE* outputFile;
	List symboleTable;
	InstructionsList rootTree;
	char instructionTempo[BUFFER_SIZE];
	
%}

%union {

	char* String;
	InstructionsList tree;

}


%start programme

%token<String> DEFINE
%token<String> ENDLINE
%token<String> FOR
%token<String> WHILE
%token<String> IF
%token<String> ELSE
%token<String> RETURN
%token<String> MAIN
%token<String> PRINTF
%token<String> PRINTI
%token<String> STENCIL
%token<String> TYPE
%token<String> ID
%token<String> CHIFFRE
%token<String> OPERATOR_NEGATION
%token<String> OPERATOR_INCREMENT
%token<String> OPERATOR_MULTI
%token<String> OPERATOR_ADDITION
%token<String> COMPARATOR_SUPREMACY
%token<String> COMPARATOR_EQUALITY
%token<String> COMPARATOR_AND
%token<String> COMPARATOR_OR
%token<String> EQUALS
%token<String> AFFECT
%token<String> OPERATOR_STENCIL
%token<String> LBRA
%token<String> RBRA
%token<String> LHOO
%token<String> RHOO
%token<String> LEMB
%token<String> REMB
%token<String> COMMA
%token<String> SEMI
%token<String> STRING

%type<tree> programme
%type<tree> preprocessor_instructions_serie
%type<tree> preprocessor_instruction
%type<tree> functions_serie
%type<tree> main
%type<tree> instructions_serie
%type<tree> ligne
%type<tree> return
%type<tree> variable
%type<tree> hooks
%type<tree> initialisation
%type<tree> variables_init_serie
%type<tree> variable_init
%type<tree> affectation
%type<tree> for
%type<tree> while
%type<tree> if
%type<tree> else
%type<tree> evaluation
%type<tree> variable_incr
%type<String> chiffre 			//cas particulier renvoie un String contenant "i"|"+i"|"-i" 

%left COMPARATOR_OR
%left COMPARATOR_AND
%left COMPARATOR_EQUALITY
%left COMPARATOR_SUPREMACY
%left OPERATOR_ADDITION
%left OPERATOR_MULTI
%left OPERATOR_INCREMENT
%left OPERATOR_NEGATION

%%

//=================================================================================================
//				La structure d'un programme
//=================================================================================================

programme :
// ------------------------------------------------------------------
preprocessor_instructions_serie functions_serie {
	printf("preprocessor_instructions_serie functions_serie -> programme\n");
}
;

//__________________________________________________________________________________

preprocessor_instructions_serie :
// ------------------------------------------------------------------
preprocessor_instruction preprocessor_instructions_serie {
	printf("preprocessor_instruction preprocessor_instructions_serie -> preprocessor_instructions_serie\n");
}
// ------------------------------------------------------------------
| {
}
;

//__________________________________________________________________________________

preprocessor_instruction :
// ------------------------------------------------------------------
DEFINE ID chiffre ENDLINE {
	printf("DEFINE ID chiffre ENDLINE -> preprocessor_instruction\n");
}
;

//__________________________________________________________________________________

functions_serie :
// ------------------------------------------------------------------
main {
	printf("main -> functions_serie\n");
}
;

//__________________________________________________________________________________

main :
// ------------------------------------------------------------------
TYPE MAIN LBRA RBRA LEMB instructions_serie REMB {
	printf("TYPE MAIN LBRA RBRA LEMB instructions_serie REMB -> main\n");
}
;

//__________________________________________________________________________________

instructions_serie :
// ------------------------------------------------------------------
ligne instructions_serie {
	printf("ligne instructions_serie -> instructions_serie\n");
}
// ------------------------------------------------------------------
| {
}
;

//__________________________________________________________________________________

ligne :
// ------------------------------------------------------------------
for {
	printf("for -> ligne\n");
}
// ------------------------------------------------------------------
| while {
	printf("while -> ligne\n");
}
// ------------------------------------------------------------------
| if {
	printf("if -> ligne\n");
}
// ------------------------------------------------------------------
| LEMB instructions_serie REMB {
	printf("LEMB instructions_serie REMB -> ligne\n");
}
// ------------------------------------------------------------------
| initialisation SEMI {
	printf("initialisation SEMI -> ligne\n");
}
// ------------------------------------------------------------------
| affectation SEMI {
	printf("affectation SEMI -> ligne\n");
}
// ------------------------------------------------------------------
| return SEMI {
	printf("return SEMI -> ligne\n");
}
// ------------------------------------------------------------------
| evaluation SEMI {
	printf("evaluation SEMI -> ligne\n");
	instructionPrint($1);
}
;

//__________________________________________________________________________________

return :
// ------------------------------------------------------------------
RETURN evaluation {
	printf("RETURN evaluation -> return\n");
}
;

//=================================================================================================
//				Les variables
//=================================================================================================

stencil :
// ------------------------------------------------------------------
ID LEMB CHIFFRE COMMA CHIFFRE REMB {
	printf("ID LEMB CHIFFRE COMA CHIFFRE REMB -> stencil\n");
}

//__________________________________________________________________________________

variable :
// ------------------------------------------------------------------
ID hooks {
	printf("ID hooks -> variable\n");
}
;

//__________________________________________________________________________________

hooks :
// ------------------------------------------------------------------
LHOO evaluation RHOO hooks {
	printf("LHOO evaluation RHOO -> hooks\n");
}
// ------------------------------------------------------------------
| {
}
;

//__________________________________________________________________________________

initialisation :
// ------------------------------------------------------------------
TYPE variables_init_serie {
	printf("TYPE variables_init_serie -> initialisation\n");
}
// ------------------------------------------------------------------
| STENCIL suite_stencil_init {
	printf("STENCIL suite_stencil_init -> initialisation\n");
}
;

//__________________________________________________________________________________

variables_init_serie :
// ------------------------------------------------------------------
variable_init COMMA variables_init_serie {printf("variable_init COMA variables_init_serie -> variables_init_serie\n");
}
// ------------------------------------------------------------------
| variable_init {
	printf("variable_init -> variables_init_serie\n");
}
;

//__________________________________________________________________________________

suite_stencil_init :
// ------------------------------------------------------------------
stencil_init COMMA suite_stencil_init {printf("stencil_init COMA suite_stencil_init -> suite_stencil_init\n");
}
// ------------------------------------------------------------------
| stencil_init {
	printf("stencil_init -> suite_stencil_init\n");
}
;

//__________________________________________________________________________________

variable_init :
// ------------------------------------------------------------------
variable EQUALS evaluation {
	printf("variable EQUALS evaluation -> variable_init\n");
}
// ------------------------------------------------------------------
| variable EQUALS LEMB suite_chiffre REMB {
	printf("variable EQUALS LEMB suite_int REMB -> variable_init\n");
}
// ------------------------------------------------------------------
| variable {
	printf("variable -> variable_init\n");
}
;

//__________________________________________________________________________________

stencil_init :
// ------------------------------------------------------------------
stencil EQUALS LEMB suite_suite_chiffre REMB {
	printf("stencil EQUALS LEMB suite_suite_chiffre REMB -> stencil_init\n");
}
// ------------------------------------------------------------------
| stencil EQUALS LEMB suite_chiffre REMB {
	printf("stencil EQUALS LEMB suite_chiffre REMB -> stencil_init\n");
}
// ------------------------------------------------------------------
| stencil {
	printf("stencil -> stencil_init\n");
}
;

//__________________________________________________________________________________

suite_suite_chiffre :
// ------------------------------------------------------------------
LEMB suite_chiffre REMB COMMA suite_suite_chiffre {
	printf("LEMB suite_chiffre REMB COMMA suite_suite_chiffre -> suite_suite_chiffre\n");
}
// ------------------------------------------------------------------
| LEMB suite_chiffre REMB {
	printf("LEMB suite_chiffre REMB -> suite_suite_chiffre\n");
}
;

//__________________________________________________________________________________

suite_chiffre :
// ------------------------------------------------------------------
chiffre COMMA suite_chiffre {
	printf("chiffre COMMA suite_chiffre -> suite_chiffre\n");
}
// ------------------------------------------------------------------
| chiffre {
	printf("chiffre -> suite_chiffre\n");
}
;

//__________________________________________________________________________________

affectation :
// ------------------------------------------------------------------
variable EQUALS evaluation {
	printf("variable EQUALS evaluation -> affectation\n");
}
// ------------------------------------------------------------------
| variable AFFECT evaluation {
	printf("variable AFFECT evaluation -> affectation\n");
}
;

//=================================================================================================
//				Les instructions conditionnelles
//=================================================================================================

for :
// ------------------------------------------------------------------
FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne {
	printf("FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne -> for\n");
}
;

//__________________________________________________________________________________

while :
// ------------------------------------------------------------------
WHILE LBRA evaluation RBRA ligne {
	printf("WHILE LBRA evaluation RBA ligne -> while\n");
}
;

//__________________________________________________________________________________

if :
// ------------------------------------------------------------------
IF LBRA evaluation RBRA ligne else {
	printf("IF LBRA evaluation RBRA ligne else -> if\n");
}
;

//__________________________________________________________________________________

else :
// ------------------------------------------------------------------
ELSE ligne {
	printf("ELSE ligne -> else\n");
}
// ------------------------------------------------------------------
| {
}
;

//=================================================================================================
//				Le retour des valeurs
//=================================================================================================

evaluation :
// ------------------------------------------------------------------ DONE
evaluation COMPARATOR_OR {
	fprintf(outputFile,"move $t9 $t0\n");
} evaluation {
	$$ = $1;
	PUSH_BACK($$,1,"bne $0 $t0 COMP_OR_%llu_RETURN_TRUE",labelCounter); 	//si $t0 != 0 => TRUE
	instructionConcat($$,$4);
	instructionListFree($4);
	PUSH_BACK($$,1,"bne $0 $t0 COMP_OR_%llu_RETURN_TRUE",labelCounter); 	//si $t0 != 0 => TRUE
	PUSH_BACK($$,1,"li $t0 0");	
	PUSH_BACK($$,1,"j COMP_OR_%llu_FIN",labelCounter);
	PUSH_BACK($$,1,"COMP_OR_%llu_RETURN_TRUE :",labelCounter);
	PUSH_BACK($$,1,"li $t0 1");	
	PUSH_BACK($$,1,"COMP_OR_%llu_FIN :",labelCounter);	
	++labelCounter;
	
	printf("evaluation COMPARATOR_OR evaluation -> evaluation\n");

	fprintf(outputFile,"beq $0 $t9 OPPE_BOOL_%llu\n",labelCounter);
	fprintf(outputFile,"li $t9 1\nj OPPE_BOOL_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_BOOL_%llu :\nli $t9 0\nOPPE_BOOL_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;

	fprintf(outputFile,"beq $0 $t0 OPPE_BOOL_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 1\nj OPPE_BOOL_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_BOOL_%llu :\nli $t0 0\nOPPE_BOOL_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;

	fprintf(outputFile,"add $t0 $t9 $t0\n");

	fprintf(outputFile,"beq $0 $t0 COMP_OR_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 1\nj COMP_OR_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"COMP_OR_%llu :\nli $t0 0\nCOMP_OR_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE
| evaluation COMPARATOR_AND {
	fprintf(outputFile,"move $t8 $t0\n");
} evaluation {
	$$ = $1;
	PUSH_BACK($$,1,"beq $0 $t0 COMP_AND_%llu_RETURN_FALSE",labelCounter); 	//si $t0 != 0 => TRUE
	instructionConcat($$,$4);
	instructionListFree($4);
	PUSH_BACK($$,1,"beq $0 $t0 COMP_AND_%llu_RETURN_FALSE",labelCounter); 	//si $t0 != 0 => TRUE
	PUSH_BACK($$,1,"li $t0 1");	
	PUSH_BACK($$,1,"j COMP_AND_%llu_FIN",labelCounter);
	PUSH_BACK($$,1,"COMP_AND_%llu_RETURN_FALSE :",labelCounter);
	PUSH_BACK($$,1,"li $t0 0");	
	PUSH_BACK($$,1,"COMP_AND_%llu_FIN :",labelCounter);
	++labelCounter;	
	
	printf("evaluation COMPARATOR_AND evaluation -> evaluation\n");

	fprintf(outputFile,"beq $0 $t8 OPPE_BOOL_%llu\n",labelCounter);
	fprintf(outputFile,"li $t8 1\nj OPPE_BOOL_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_BOOL_%llu :\nli $t8 0\nOPPE_BOOL_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;

	fprintf(outputFile,"beq $0 $t0 OPPE_BOOL_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 1\nj OPPE_BOOL_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_BOOL_%llu :\nli $t0 0\nOPPE_BOOL_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;

	fprintf(outputFile,"sub $t0 $t8 $t0\n");

	fprintf(outputFile,"beq $0 $t0 COMP_AND_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 0\nj COMP_AND_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"COMP_AND_%llu :\nli $t0 1\nCOMP_AND_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE 
| evaluation COMPARATOR_EQUALITY {
	fprintf(outputFile,"move $t7 $t0\n");
} evaluation {
	instructionListMalloc(&$$); // pour evité les core dumpt
	char inst[4];
	printf("evaluation COMPARATOR_EQUALITY evaluation -> evaluation\n");
	if(!strcmp($2,"==")){
		strcpy(inst,"beq");
	}else if(!strcmp($2,"!=")){
		strcpy(inst,"bne");
	}
	
	$$ = $1;
	PUSH_BACK($$,1,"move $t7 $t0");
	instructionConcat($$,$4);
	instructionListFree($4);
	PUSH_BACK($$,1,"%s $t7 $t0 COMP_EQUALITY_%llu_RETURN_TRUE\n",inst,labelCounter);
	PUSH_BACK($$,1,"li $t0 0");
	PUSH_BACK($$,1,"j COMP_EQUALITY_%llu_FIN\n",labelCounter);
	PUSH_BACK($$,1,"COMP_EQUALITY_%llu_RETURN_TRUE :",labelCounter);
	PUSH_BACK($$,1,"li $t0 1");	
	PUSH_BACK($$,1,"COMP_EQUALITY_%llu_FIN :",labelCounter);
	++labelCounter;
	
	
	fprintf(outputFile,"%s $t7 $t0 COMP_EQUALITY_%llu\n",inst,labelCounter);
	fprintf(outputFile,"li $t0 0\nj COMP_EQUALITY_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"COMP_EQUALITY_%llu :\nli $t0 1\nCOMP_EQUALITY_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE 
| evaluation COMPARATOR_SUPREMACY {
	fprintf(outputFile,"move $t6 $t0\n");
} evaluation {
	instructionListMalloc(&$$); // pour evité les core dumpt
	char inst[4];
	printf("evaluation COMPARATOR_SUPREMACY evaluation -> evaluation\n");
	if(!strcmp($2,"<")){
		strcpy(inst,"blt");
	}else if(!strcmp($2,"<=")){
		strcpy(inst,"ble");
	}else if(!strcmp($2,">")){
		strcpy(inst,"bgt");
	}else if(!strcmp($2,">=")){
		strcpy(inst,"bge");
	}
	
	$$ = $1;
	PUSH_BACK($$,1,"move $t6 $t0");
	instructionConcat($$,$4);
	instructionListFree($4);
	PUSH_BACK($$,1,"%s $t6 $t0 COMP_SUPREMACY_%llu_RETURN_TRUE\n",inst,labelCounter);
	PUSH_BACK($$,1,"li $t0 0");
	PUSH_BACK($$,1,"j COMP_SUPREMACY_%llu_FIN\n",labelCounter);
	PUSH_BACK($$,1,"COMP_SUPREMACY_%llu_RETURN_TRUE :",labelCounter);
	PUSH_BACK($$,1,"li $t0 1");	
	PUSH_BACK($$,1,"COMP_SUPREMACY_%llu_FIN :",labelCounter);
	++labelCounter;
	
	fprintf(outputFile,"%s $t6 $t0 COMP_SUPREMACY_%llu\n",inst,labelCounter);
	fprintf(outputFile,"li $t0 0\nj COMP_SUPREMACY_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"COMP_SUPREMACY_%llu :\nli $t0 1\nCOMP_SUPREMACY_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE
| evaluation OPERATOR_ADDITION {
	fprintf(outputFile,"move $t5 $t0\n");
} evaluation {
	$$ = $1;
	PUSH_FORWARD($4,1,"move $t5 $t0");
	instructionConcat($$,$4);
	instructionListFree($4);
	printf("evaluation OPERATOR_ADDITION evaluation -> evaluation\n");
	if($2[0] == '+'){
		fprintf(outputFile,"add $t0 $t5 $t0\n");
		PUSH_BACK($$,1,"add $t0 $t5 $t0");
	}else{
		fprintf(outputFile,"sub $t0 $t5 $t0\n");
		PUSH_BACK($$,1,"sub $t0 $t5 $t0");
	}
}
// ------------------------------------------------------------------ DONE
| evaluation OPERATOR_MULTI {
	fprintf(outputFile,"move $t4 $t0\n");
} evaluation {
	$$ = $1;
	PUSH_FORWARD($4,1,"move $t4 $t0");
	instructionConcat($$,$4);
	instructionListFree($4);
	printf("evaluation OPERATOR_MULTI evaluation -> evaluation\n");
	if($2[0] == '*'){
		fprintf(outputFile,"mul $t0 $t4 $t0\n");
		PUSH_BACK($$,1,"mul $t0 $t4 $t0");
	}else{
		fprintf(outputFile,"div $t0 $t4 $t0\n");
		PUSH_BACK($$,1,"div $t0 $t4 $t0");
	}
}
// ------------------------------------------------------------------ DONE
| LBRA {
	int i;
	fprintf(outputFile,"subi $sp $sp %d\n",4*9);
	for(i=1 ; i<=9 ; ++i)
	{
		fprintf(outputFile,"sw $t%d %d($sp)\n",i,i*4);
	}
} evaluation RBRA {
	int i;
	instructionListMalloc(&$$);
	PUSH_BACK($$,1,"subi $sp $sp %d",4*9);
	for(i=1 ; i<=9 ; ++i)
	{
		PUSH_BACK($$,1,"sw $t%d %d($sp)",i,i*4);
	}
	instructionIncr($3,1);
	instructionConcat($$,$3);
	instructionListFree($3);
	printf("LBRA evaluation RBRA -> evaluation\n");
	for(i=1 ; i<=9 ; ++i)
	{
		fprintf(outputFile,"lw $t%d %d($sp)\n",i,i*4);
		PUSH_BACK($$,1,"lw $t%d %d($sp)",i,i*4);
	}
	fprintf(outputFile,"addi $sp $sp %d\n",4*9);
	PUSH_BACK($$,1,"addi $sp $sp %d",4*9);
}
// ------------------------------------------------------------------ DONE
| PRINTI LBRA evaluation RBRA {
	printf("PRINTI LBRA evaluation RBRA -> evaluation\n");
	$$ = $3;
	instructionPushBack($$,"move $a0 $t0",1);
	instructionPushBack($$,"li $v0 1",1);
	instructionPushBack($$,"syscall",1);
	fprintf(outputFile,"move $a0 $t0\nli $v0 1\nsyscall\n");
}
// ------------------------------------------------------------------
| PRINTF LBRA STRING RBRA {
	instructionListMalloc(&$$); // pour evité les core dumpt
	printf("PRINTF LBRA STRING RBRA -> evaluation\n");
}
// ------------------------------------------------------------------ DONE
| OPERATOR_NEGATION evaluation {
	printf("OPERATOR_NEGATION evaluation -> evaluation\n");
	fprintf(outputFile,"beq $0 $t0 OPPE_NEG_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 0\nj OPPE_NEG_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_NEG_%llu :\nli $t0 1\nOPPE_NEG_%llu_FIN :\n",labelCounter,labelCounter);
	$$ = $2;
	PUSH_BACK($$,1,"beq $0 $t0 OPPE_NEG_%llu",labelCounter);
	instructionPushBack($$,"li $t0 0",1);
	PUSH_BACK($$,1,"j OPPE_NEG_%llu_FIN",labelCounter);
	PUSH_BACK($$,1,"OPPE_NEG_%llu :",labelCounter);
	instructionPushBack($$,"li $t0 1",1);
	PUSH_BACK($$,1,"OPPE_NEG_%llu_FIN :",labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE
| chiffre {
	printf("chiffre -> evaluation\n");
	instructionListMalloc(&$$);
	PUSH_BACK($$,1,"li $t0 %s",$1);
	fprintf(outputFile,"li $t0 %s\n",$1);
}
// ------------------------------------------------------------------
| variable_incr	{
	instructionListMalloc(&$$); // pour evité les core dumpt sera surement $$ = $1
	printf("variable_incr -> evaluation\n");
}
;

//__________________________________________________________________________________

variable_incr :
// ------------------------------------------------------------------ 
OPERATOR_INCREMENT variable	{
	printf("OPERATOR_INCREMENT variable -> variable_incr\n");
// pour ++
// addi $variable 1
// move $t0 $variable
}
// ------------------------------------------------------------------
| variable OPERATOR_INCREMENT {
	printf("variable OPERATOR_INCREMENT -> variable_incr\n");
// pour ++
// move $t0 $variable
// addi $varibale 1
}
// ------------------------------------------------------------------
| variable {
	printf("variable -> variable_incr\n");
// move $t0 $variable
}
;

//__________________________________________________________________________________

chiffre :
// ------------------------------------------------------------------ DONE
CHIFFRE {
	printf("CHIFFRE -> chiffre\n");
	sprintf($$,"%s",$1);
}
// ------------------------------------------------------------------ DONE
| OPERATOR_ADDITION CHIFFRE {
	printf("OPERATOR_ADDITION CHIFFRE -> chiffre\n");
	sprintf($$,"%s%s",$1,$2);
}
;

%%//==============================================================================================

void instructionFirstUsing(InstructionsList l, char* c, int i){
	*l = (Instruction)instructionMalloc(c, i);
}

int main(void)
{
	symboleTable = mallocList();
	Instruction firstInst = instructionMalloc(".data",0);
	rootTree = &firstInst;
	
	outputFile = fopen("output.mips","w");

	fprintf(outputFile,".data\n.text\n.globl main\n\nmain :\n");

	yyparse();

	fprintf(outputFile,"\nExit :\nla $v0 10\nsyscall\n");
	
	fclose(outputFile);
	freeList(symboleTable);
	instructionPrint(rootTree);
	instructionFree(rootTree);

	return EXIT_SUCCESS;
}

void yyerror (char const *s)
{
	printf("error : %s %d\n",s, yychar);

	// fclose(outputFile);
	// freeList(symboleTable);
}