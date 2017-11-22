%code requires {
    #include "InstructionsList.h"
    #include "SymbolsTable.h"
}

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "InstructionsList.h"
	#include "SymbolsTable.h"

	#ifdef DEBUG
	#define printf(args...) printf(args);
	#else
	#define printf(...)
	#endif

	#define PUSH_BACK(dest, indent, code...) 	snprintf(instructionTempo,INSTRUCTION_SIZE,code);\
												instructionPushBack(dest,instructionTempo,indent)

	#define PUSH_FORWARD(dest, indent, code...) snprintf(instructionTempo,INSTRUCTION_SIZE,code);\
												instructionPushForward(dest,instructionTempo,indent)

	#define ERROR(msg...) 	snprintf(instructionTempo,INSTRUCTION_SIZE,msg);\
							yyerror(instructionTempo)

	#define INSTRUCTION_SIZE 50

	extern int yylineno;

	unsigned long long labelCounter = 0;
	unsigned long long variableCounter = 0;

	int yylex();
	void yyerror (char const*);

	FILE* outputFile;
	SymbolsTable symbolsTable;
	InstructionsList rootTree;
	char instructionTempo[INSTRUCTION_SIZE];
	Array* actualArrayInit;
	
%}

%union {

	char* String;
	InstructionsList Instruction;
	Symbol Sym;
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
%token<String> NUMBER
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

%type<Instruction> programme
%type<Instruction> functions_serie
%type<Instruction> main
%type<Instruction> instructions_serie
%type<Instruction> ligne
%type<Instruction> write_ligne_number
%type<Instruction> return
%type<Sym> 		   variable			//cas particulier renvoie le symbole de la table des symbole
%type<Instruction> hooks
%type<Instruction> initialisation
%type<Instruction> variables_init_serie
%type<Instruction> stencils_init_serie
%type<Instruction> variable_init
%type<Instruction> stencil_init
%type<Instruction> unit_init
%type<Instruction> array_init
%type<Instruction> hooks_init
%type<Instruction> affectation
%type<Instruction> for
%type<Instruction> while
%type<Instruction> if
%type<Instruction> else
%type<Instruction> evaluation
%type<Instruction> variable_incr
%type<String>      number 			//cas particulier renvoie un String contenant "i"|"+i"|"-i" 

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
// -1-------------------------------2-------------------------------- DONE
	preprocessor_instructions_serie functions_serie {
		printf("preprocessor_instructions_serie functions_serie -> programme\n");
		
		PUSH_FORWARD(rootTree,0,".data");
		PUSH_BACK(rootTree,0,"\n#####\n\n.globl __main");
		PUSH_BACK(rootTree,0,"\n#####\n\n.text");
		
		instructionConcat(rootTree,$2);
		
		PUSH_BACK(rootTree,0,"\n#####\n\nExit :\n");
		PUSH_BACK(rootTree,1,"li $v0 10");
		PUSH_BACK(rootTree,1,"syscall");
	}
	;

//__________________________________________________________________________________

preprocessor_instructions_serie :
// -1------------------------2--------------------------------------- DONE
	preprocessor_instruction preprocessor_instructions_serie {
		printf("preprocessor_instruction preprocessor_instructions_serie -> preprocessor_instructions_serie\n");
	}
// ------------------------------------------------------------------
	| {
	}
	;

//__________________________________________________________________________________

preprocessor_instruction :
// -1------2--3------4----------------------------------------------- DONE
	DEFINE ID number ENDLINE {
		printf("DEFINE ID number ENDLINE -> preprocessor_instruction\n");
		
		if(symbolsTableGetSymbolById(symbolsTable,$2) != NULL){
			ERROR("La variable '%s' existe deja !",$2); 	
		}
		symbolsTableAddSymbolConstUnit(symbolsTable,$2,atoi($3));
	}
	;

//__________________________________________________________________________________

functions_serie :
// -1---------------------------------------------------------------- DONE
	main {
		printf("main -> functions_serie\n");
		
		$$ = $1;
	}
	;

//__________________________________________________________________________________

main :
// -1----2----3----4----5----7------------------8-------------------- DONE
	TYPE MAIN LBRA RBRA LEMB instructions_serie REMB {
		printf("TYPE MAIN LBRA RBRA LEMB instructions_serie REMB -> main\n");
		
		$$ = $6;
		PUSH_FORWARD($$,0,"\n__main :");
		PUSH_BACK($$,1,"j Exit");
	}
	;

//__________________________________________________________________________________

instructions_serie :
// -1-----2---------------------------------------------------------- DONE
	ligne instructions_serie {
		printf("ligne instructions_serie -> instructions_serie\n");
		
		$$ = $1;
		instructionConcat($$,$2);
	}
// ------------------------------------------------------------------ DONE
	| {
		instructionListMalloc(&$$);
	}
	;

//__________________________________________________________________________________

ligne :
// -1-----------2---------------------------------------------------- DONE
	write_ligne_number for {
		printf("for -> ligne\n");
		
		$$ = $1;
		instructionConcat($$,$2);
	}
// ---1-------------------------------------------------------------- DONE
	| write_ligne_number while {
		printf("while -> ligne\n");
		
		$$ = $1;
		instructionConcat($$,$2);
	}
// ---1-------------------------------------------------------------- DONE
	| write_ligne_number if {
		printf("if -> ligne\n");
		
		$$ = $1;
		instructionConcat($$,$2);
	}
// ---1----2----3------------------4--------------------------------- DONE
	| LEMB step_begin instructions_serie step_end REMB {
		printf("LEMB instructions_serie REMB -> ligne\n");
		
		$$ = $3;
		instructionIncr($$,1);
		PUSH_FORWARD($$,1,"#{");
		PUSH_BACK($$,1,"#}");
	}
// ---1--------------2----------------------------------------------- DONE
	| write_ligne_number initialisation SEMI {
		printf("initialisation SEMI -> ligne\n");
		
		$$ = $1;
		instructionConcat($$,$2);
	}
// ---1-----------2-------------------------------------------------- DONE
	| write_ligne_number affectation SEMI {
		printf("affectation SEMI -> ligne\n");
		
		$$ = $1;
		instructionConcat($$,$2);
	}
// ---1------2-------------------------------------------------------
	| write_ligne_number return SEMI {
		printf("return SEMI -> ligne\n");
		
		$$ = $1;
	}
// ---1----------2--------------------------------------------------- DONE
	| write_ligne_number evaluation SEMI {
		printf("evaluation SEMI -> ligne\n");
		
		$$ = $1;
		instructionConcat($$,$2);
	}
	;

//__________________________________________________________________________________

step_begin : 
// ------------------------------------------------------------------ DONE
	{ 
		symbolsTableAddStep(symbolsTable); 
	}
	;
	
//__________________________________________________________________________________

step_end : 
// ------------------------------------------------------------------ DONE
	{ 
		symbolsTableRemoveUntilStep(symbolsTable); 
	}
	;

//__________________________________________________________________________________

write_ligne_number : 
// ------------------------------------------------------------------ DONE
	{ 
		instructionListMalloc(&$$);
		PUSH_FORWARD($$,1,"#---------- : %d ----------",yylineno);
	}
	;

//__________________________________________________________________________________

return :
// -1------2---------------------------------------------------------
	RETURN evaluation {
		printf("RETURN evaluation -> return\n");
	}
	;

//=================================================================================================
//				Les variables
//=================================================================================================

stencil :
// -1--2----3------4-----5------6------------------------------------
	ID LEMB NUMBER COMMA NUMBER REMB {
		printf("ID LEMB NUMBER COMA NUMBER REMB -> stencil\n");
	}

//__________________________________________________________________________________

variable :
// -1--2------------------------------------------------------------- DONE TODO check if array
	ID hooks {
		printf("ID hooks -> variable\n");

		Symbol s;
		if( (s=symbolsTableGetSymbolById(symbolsTable,$1)) == NULL){
			ERROR("La variable '%s' n'existe pas !",$1); 
		}

		$$ = s;
	}
	;

//__________________________________________________________________________________

hooks :
// -1----2----------3----4-------------------------------------------
	LHOO evaluation RHOO hooks {
		printf("LHOO evaluation RHOO -> hooks\n");
	}
// ------------------------------------------------------------------
	| {
	}
	;

//=================================================================================================
//				Les initialisations de variables et stencil
//=================================================================================================

initialisation :
// -1----2----------------------------------------------------------- DONE
	TYPE variables_init_serie {
		printf("TYPE variables_init_serie -> initialisation\n");
		
		$$ = $2;
	}
// ---1-------2------------------------------------------------------ DONE
	| STENCIL stencils_init_serie {
		printf("STENCIL stencils_init_serie -> initialisation\n");
		
		$$ = $2;
	}
	;

//__________________________________________________________________________________

variables_init_serie :
// -1-------------2-----3-------------------------------------------- DONE
	variable_init COMMA variables_init_serie {
		printf("variable_init COMA variables_init_serie -> variables_init_serie\n");
		
		$$ = $1;
		instructionConcat($$,$3);
	}
// ---1-------------------------------------------------------------- DONE
	| variable_init {
		printf("variable_init -> variables_init_serie\n");
		
		$$ = $1;
	}
	;

//__________________________________________________________________________________

stencils_init_serie :
// -1------------2-----3--------------------------------------------- DONE
	stencil_init COMMA stencils_init_serie {
		printf("stencil_init COMA stencils_init_serie -> stencils_init_serie\n");
		
		$$ = $1;
		instructionConcat($$,$3);
	}
// ---1-------------------------------------------------------------- DONE
	| stencil_init {
		printf("stencil_init -> stencils_init_serie\n");
		
		$$ = $1;
	}
	;	

//__________________________________________________________________________________ 

variable_init :		
// -1---------------------------------------------------------------- 
	unit_init {
		$$ = $1;
	}
// ---1-------------------------------------------------------------- 
	| array_init {
		$$ = $1;
	}
	;

//__________________________________________________________________________________

unit_init :
// -1--2------3------------------------------------------------------ DONE
	ID EQUALS evaluation {
		printf("ID EQUALS evaluation -> variable_init\n");

		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			ERROR("La variable '%s' existe deja !",$1); 	
		}
		Symbol result = symbolsTableAddSymbolUnit(symbolsTable,$1,true);
		$$ = $3;
		PUSH_BACK($$,1,"sw $t0 %s",((Unit*)result->data)->mipsId);
		
	}
// ---1-------------------------------------------------------------- DONE
	| ID {
		printf("ID -> variable_init\n");

		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			ERROR("La variable '%s' existe deja !",$1); 	
		}
		symbolsTableAddSymbolUnit(symbolsTable,$1,false);
		instructionListMalloc(&$$);
	}
	
//__________________________________________________________________________________


array_init :	
// -1--2----------3------4----5------------------6-------------------
	array_init_begin hooks_init EQUALS LEMB suite_suite_number REMB {
		printf("ID hooks_init EQUALS LEMB suite_suite_number REMB -> array_init\n");

		$$ = $2;		
	}
// ---1--2----------3------4----5------------6-----------------------
	| array_init_begin hooks_init EQUALS LEMB suite_number REMB {
		printf("ID hooks_init EQUALS LEMB suite_number REMB -> array_init\n");
		
		$$ = $2;
	}
// ---1--2----------------------------------------------------------- DONE
	| array_init_begin hooks_init {
		printf("ID hooks_init -> array_init\n");
		
		$$ = $2;
	}


array_init_begin : 
// -1--2------------------------------------------------------------- DONE
	ID LHOO {
		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			ERROR("La variable '%s' existe deja !",$1); 	
		}
		actualArrayInit = symbolsTableAddArray(symbolsTable,$1)->data;
	}
	;
	
//__________________________________________________________________________________

hooks_init :
// -1----------2----3----------4------------------------------------- DONE COMMENT TODO 
	hooks_init LHOO evaluation RHOO  {
		printf("LHOO evaluation RHOO hooks_init -> hooks_init\n");
		
		$$ = $1;
		instructionConcat($$,$3);//mutiplie par 4 (taille int)
		
		
		//calcul du tableau de la dimension suivante +creation 
		PUSH_BACK($$,1,"mul $a0 $s5 $t0");
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		
		//multiplication de $t0 par 4 pour l'itération dans le tableau
		PUSH_BACK($$,1,"sll $t0 $t0 2"); 
		PUSH_BACK($$,1,"move $t2 $v0");
		//relié les deux tableau
			//init du FOR
			PUSH_BACK($$,1,"li $t1 0");
			PUSH_BACK($$,1,"LOOP_HOOKS_INIT_%llu_BEGIN : ",labelCounter);
			PUSH_BACK($$,1,"bge $t1 $s5 LOOP_HOOKS_INIT_%llu_END",labelCounter);
			
			//traitement du FOR
			PUSH_BACK($$,1,"sw $v0 0($s4)");
			
			//incrément du FOR + j BEGIN
			PUSH_BACK($$,1,"add $t1 $t1 4");
			PUSH_BACK($$,1,"add $v0 $v0 $t0");
			PUSH_BACK($$,1,"add $s4 $s4 4");
			
			PUSH_BACK($$,1,"j LOOP_HOOKS_INIT_%llu_BEGIN ",labelCounter);
			PUSH_BACK($$,1,"LOOP_HOOKS_INIT_%llu_END : ",labelCounter);
			labelCounter++;
		
		//préparer l'itération suivante
		PUSH_BACK($$,1,"move $4 $t2");
		PUSH_BACK($$,1,"move $5 $a0");
		
		actualArrayInit->nbDimension++;
	}
// ---1----2--------------------------------------------------------- DONE COMMENT TODO 
	| evaluation RHOO {
		printf("LHOO evaluation RHOO -> hooks_init\n");
		
		$$ = $1;
		
		PUSH_BACK($$,1,"sll $t0 $t0 2"); //mutiplie par 4 (taille int)
		//on stock la taille(total) du tableau dans s5
		PUSH_BACK($$,1,"move $s5 $t0");
		
		//créé tableau taille dans evaluation ($t0) le mettre dans mipsId
		PUSH_BACK($$,1,"move $a0 $t0"); 
		PUSH_BACK($$,1,"li  $v0 9");
		PUSH_BACK($$,1,"syscall");
		//pointeur dans v0
		PUSH_BACK($$,1,"sw $v0 %s",actualArrayInit->mipsId);
		
		//enregistrement du pointeur du tableau s4
		PUSH_BACK($$,1,"move $s4 $v0");
		

		actualArrayInit->nbDimension++;
	}
	;

//__________________________________________________________________________________

stencil_init :
// -1-------2------3----4------------------5-------------------------
	stencil EQUALS LEMB suite_suite_number REMB {
		printf("stencil EQUALS LEMB suite_suite_number REMB -> stencil_init\n");
		
		instructionListMalloc(&$$);
	}
// ---1-------2------3----4------------5-----------------------------
	| stencil EQUALS LEMB suite_number REMB {
		printf("stencil EQUALS LEMB suite_number REMB -> stencil_init\n");
		
		instructionListMalloc(&$$);
	}
// ---1--------------------------------------------------------------
	| stencil {
		printf("stencil -> stencil_init\n");
		
		instructionListMalloc(&$$);
	}
	;

//__________________________________________________________________________________

suite_suite_number :
// -1----2------------3----4-----5-----------------------------------
	LEMB suite_number REMB COMMA suite_suite_number {
		printf("LEMB suite_number REMB COMMA suite_suite_number -> suite_suite_number\n");
	}
// ---1----2------------3--------------------------------------------
	| LEMB suite_number REMB {
		printf("LEMB suite_number REMB -> suite_suite_number\n");
	}
	;

//__________________________________________________________________________________

suite_number :
// -1------2-----3---------------------------------------------------
	number COMMA suite_number {
		printf("number COMMA suite_number -> suite_number\n");
	}
// ---1--------------------------------------------------------------
	| number {
		printf("number -> suite_number\n");
	}
	;

//=================================================================================================
//				Les affectations de variables
//=================================================================================================

affectation :
// -1--------2------3------------------------------------------------ DONE TODO check if array
	variable EQUALS evaluation {
		printf("variable EQUALS evaluation -> affectation\n");

		$$ = $3;
		switch($1->type){
			case unit :
				PUSH_BACK($$,1,"sw $t0 %s",((Unit*)$1->data)->mipsId);
				((Unit*)$1->data)->init = true;
				break;
			case constUnit :
				ERROR("La variable '%s' a ete declare constante !",((ConstUnit*)$1->data)->id); 				
				break;
			default :
				ERROR("TODO variable EQUALS evaluation");
		}
	}
// ---1--------2------3---------------------------------------------- DONE TODO check if array
	| variable AFFECT evaluation {
		printf("variable AFFECT evaluation -> affectation\n");

		$$ = $3;
		switch($1->type){
			case unit :
				if(((Unit*)$1->data)->init == false){
					ERROR("La variable '%s' est utilise mais pas initialise !",((Unit*)$1->data)->id); 				
				}
				PUSH_BACK($$,1,"lw $t1 %s",((Unit*)$1->data)->mipsId);
				if(!strcmp($2,"+=")){
					PUSH_BACK($$,1,"add $t0 $t1 $t0");
				}else if(!strcmp($2,"-=")){
					PUSH_BACK($$,1,"sub $t0 $t1 $t0");
				}else if(!strcmp($2,"*=")){
					PUSH_BACK($$,1,"mul $t0 $t1 $t0");
				}else if(!strcmp($2,"/=")){
					PUSH_BACK($$,1,"div $t0 $t1 $t0");
				}else if(!strcmp($2,"%=")){
					PUSH_BACK($$,1,"div $t2 $t1 $t0");
					PUSH_BACK($$,1,"mul $t2 $t2 $t0");
					PUSH_BACK($$,1,"sub $t0 $t1 $t2");
				}
				PUSH_BACK($$,1,"sw $t0 %s",((Unit*)$1->data)->mipsId);
				break;
			case constUnit :
				ERROR("La variable '%s' a ete declare constante !",((ConstUnit*)$1->data)->id); 				
				break;
			default :
				ERROR("TODO variable OPERATOR_INCREMENT");
		}
	}
	;

//=================================================================================================
//				Les instructions conditionnelles
//=================================================================================================

for :
// -1---2----3-----------4----5----------6----7----------8----9----------10----11- DONE
	FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA step_begin ligne step_end {
		printf("FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne -> for\n");
		
		$$ = $3;	
		PUSH_BACK($$,1,"LOOP_FOR_%llu_BEGIN :",labelCounter);
		instructionConcat($$,$5);
		PUSH_BACK($$,1,"beq $0 $t0 LOOP_FOR_%llu_END",labelCounter);
		instructionConcat($$,$10);
		instructionConcat($$,$7);
		PUSH_BACK($$,1,"j LOOP_FOR_%llu_BEGIN",labelCounter);
		PUSH_BACK($$,1,"LOOP_FOR_%llu_END :",labelCounter);
		labelCounter++;
	}
	;

//__________________________________________________________________________________

while :
// -1-----2----3----------4----5----------6-----7-------------------- DONE
	WHILE LBRA evaluation RBRA step_begin ligne step_end {
		printf("WHILE LBRA evaluation RBA ligne -> while\n");
		
		$$ = $3;
		PUSH_FORWARD($$,1,"LOOP_WHILE_%llu_BEGIN :",labelCounter);
		PUSH_BACK($$,1,"beq $0 $t0 LOOP_WHILE_%llu_END",labelCounter);
		instructionConcat($$,$6);
		PUSH_BACK($$,1,"j LOOP_WHILE_%llu_BEGIN",labelCounter);
		PUSH_BACK($$,1,"LOOP_WHILE_%llu_END :",labelCounter);		
		labelCounter++;
	}
	;

//__________________________________________________________________________________

if :
// -1--2----3----------4----5----------6-----7--------8-------------- DONE
	IF LBRA evaluation RBRA step_begin ligne step_end else {
		printf("IF LBRA evaluation RBRA ligne else -> if\n");
		
		$$ = $3;
		PUSH_BACK($$,1,"beq $0 $t0 IF_COND_%llu_FALSE",labelCounter);
		instructionConcat($$,$6);
		PUSH_BACK($$,1,"j IF_COND_%llu_END",labelCounter);
		PUSH_BACK($$,1,"IF_COND_%llu_FALSE :",labelCounter);
		instructionConcat($$,$8);
		PUSH_BACK($$,1,"IF_COND_%llu_END :",labelCounter);
		labelCounter++;
	}
	;

//__________________________________________________________________________________

else :
// -1----2----------3-----4------------------------------------------ DONE
	ELSE step_begin ligne step_end {
		printf("ELSE ligne -> else\n");
		
		$$ = $3;
	}
// ------------------------------------------------------------------ DONE
	| {
		instructionListMalloc(&$$);
	}
	;

//=================================================================================================
//				Le retour des valeurs
//=================================================================================================

evaluation :
// -1----------2-------------3--------------------------------------- DONE
	evaluation COMPARATOR_OR evaluation {
		printf("evaluation COMPARATOR_OR evaluation -> evaluation\n");

		$$ = $1;
		PUSH_BACK($$,1,"bne $0 $t0 COMP_OR_%llu_RETURN_TRUE",labelCounter); //si $t0 != 0 => TRUE
		instructionConcat($$,$3);
		PUSH_BACK($$,1,"bne $0 $t0 COMP_OR_%llu_RETURN_TRUE",labelCounter); //si $t0 != 0 => TRUE
		PUSH_BACK($$,1,"li $t0 0");	
		PUSH_BACK($$,1,"j COMP_OR_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"COMP_OR_%llu_RETURN_TRUE :",labelCounter);
		PUSH_BACK($$,1,"li $t0 1");	
		PUSH_BACK($$,1,"COMP_OR_%llu_FIN :",labelCounter);	
		++labelCounter;
	}
// ---1----------2--------------3------------------------------------ DONE
	| evaluation COMPARATOR_AND evaluation {
		printf("evaluation COMPARATOR_AND evaluation -> evaluation\n");
		
		$$ = $1;
		PUSH_BACK($$,1,"beq $0 $t0 COMP_AND_%llu_RETURN_FALSE",labelCounter); //si $t0 == 0 => FALSE
		instructionConcat($$,$3);
		PUSH_BACK($$,1,"beq $0 $t0 COMP_AND_%llu_RETURN_FALSE",labelCounter); //si $t0 == 0 => FALSE
		PUSH_BACK($$,1,"li $t0 1");	
		PUSH_BACK($$,1,"j COMP_AND_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"COMP_AND_%llu_RETURN_FALSE :",labelCounter);
		PUSH_BACK($$,1,"li $t0 0");	
		PUSH_BACK($$,1,"COMP_AND_%llu_FIN :",labelCounter);
		++labelCounter;	
	}
// ---1----------2-------------------3------------------------------- DONE 
	| evaluation COMPARATOR_EQUALITY evaluation {
		printf("evaluation COMPARATOR_EQUALITY evaluation -> evaluation\n");

		$$ = $1;
		PUSH_BACK($$,1,"move $s3 $t0");
		instructionConcat($$,$3);
		char inst[4];
		if(!strcmp($2,"==")){
			strcpy(inst,"beq");
		}else if(!strcmp($2,"!=")){
			strcpy(inst,"bne");
		}
		PUSH_BACK($$,1,"%s $s3 $t0 COMP_EQUALITY_%llu_RETURN_TRUE",inst,labelCounter);
		PUSH_BACK($$,1,"li $t0 0");
		PUSH_BACK($$,1,"j COMP_EQUALITY_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"COMP_EQUALITY_%llu_RETURN_TRUE :",labelCounter);
		PUSH_BACK($$,1,"li $t0 1");	
		PUSH_BACK($$,1,"COMP_EQUALITY_%llu_FIN :",labelCounter);
		++labelCounter;	
	}
// ---1----------2--------------------3------------------------------ DONE 
	| evaluation COMPARATOR_SUPREMACY evaluation {
		printf("evaluation COMPARATOR_SUPREMACY evaluation -> evaluation\n");
		char inst[4];

		$$ = $1;
		PUSH_BACK($$,1,"move $s2 $t0");
		instructionConcat($$,$3);
		if(!strcmp($2,"<")){
			strcpy(inst,"blt");
		}else if(!strcmp($2,"<=")){
			strcpy(inst,"ble");
		}else if(!strcmp($2,">")){
			strcpy(inst,"bgt");
		}else if(!strcmp($2,">=")){
			strcpy(inst,"bge");
		}
		PUSH_BACK($$,1,"%s $s2 $t0 COMP_SUPREMACY_%llu_RETURN_TRUE",inst,labelCounter);
		PUSH_BACK($$,1,"li $t0 0");
		PUSH_BACK($$,1,"j COMP_SUPREMACY_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"COMP_SUPREMACY_%llu_RETURN_TRUE :",labelCounter);
		PUSH_BACK($$,1,"li $t0 1");	
		PUSH_BACK($$,1,"COMP_SUPREMACY_%llu_FIN :",labelCounter);
		++labelCounter;	
	}
// ---1----------2-----------------3--------------------------------- DONE
	| evaluation OPERATOR_ADDITION evaluation {
		printf("evaluation OPERATOR_ADDITION evaluation -> evaluation\n");

		$$ = $1;
		PUSH_FORWARD($3,1,"move $s1 $t0");
		instructionConcat($$,$3);
		if($2[0] == '+'){
			PUSH_BACK($$,1,"add $t0 $s1 $t0");
		}else{
			PUSH_BACK($$,1,"sub $t0 $s1 $t0");
		}
	}
// ---1----------2--------------3------------------------------------ DONE
	| evaluation OPERATOR_MULTI evaluation {
		printf("evaluation OPERATOR_MULTI evaluation -> evaluation\n");
		
		$$ = $1;
		PUSH_FORWARD($3,1,"move $s0 $t0");
		instructionConcat($$,$3);
		if($2[0] == '*'){
			PUSH_BACK($$,1,"mul $t0 $s0 $t0");
		}else if($2[0] == '/') {
			PUSH_BACK($$,1,"div $t0 $s0 $t0");
		}else{
			PUSH_BACK($$,1,"div $t1 $s0 $t0");
			PUSH_BACK($$,1,"mul $t1 $t1 $t0");
			PUSH_BACK($$,1,"sub $t0 $s0 $t1");
		}
	}
// ---1----2----------3---------------------------------------------- DONE
	| LBRA evaluation RBRA {
		printf("LBRA evaluation RBRA -> evaluation\n");
		int i;

		instructionListMalloc(&$$);
		PUSH_BACK($$,1,"subi $sp $sp %d",4*9);
		for(i=0 ; i<=3 ; ++i)
		{
			PUSH_BACK($$,1,"sw $s%d %d($sp)",i,i*4);
		}
		instructionIncr($2,1);
		PUSH_FORWARD($2,1,"#(");
		PUSH_BACK($2,1,"#)");
		instructionConcat($$,$2);
		for(i=0 ; i<=3 ; ++i)
		{
			PUSH_BACK($$,1,"lw $s%d %d($sp)",i,i*4);
		}
		PUSH_BACK($$,1,"addi $sp $sp %d",4*9);
	}
// ---1------2----3----------4--------------------------------------- DONE
	| PRINTI LBRA evaluation RBRA {
		printf("PRINTI LBRA evaluation RBRA -> evaluation\n");
		
		$$ = $3;
		PUSH_BACK($$,1,"move $a0 $t0");
		PUSH_BACK($$,1,"li $v0 1");
		PUSH_BACK($$,1,"syscall");
	}
// ---1------2----3------4------------------------------------------- DONE
	| PRINTF LBRA STRING RBRA {
		printf("PRINTF LBRA STRING RBRA -> evaluation\n");

		instructionListMalloc(&$$);

		PUSH_BACK(rootTree,1,"string_%llu : .asciiz %s",variableCounter,$3);
		PUSH_BACK($$,1,"la $a0 string_%llu",variableCounter++);
		PUSH_BACK($$,1,"li $v0 4");
		PUSH_BACK($$,1,"syscall");
	}
// ---1-----------------2-------------------------------------------- DONE
	| OPERATOR_NEGATION evaluation {
		printf("OPERATOR_NEGATION evaluation -> evaluation\n");
		
		$$ = $2;
		PUSH_BACK($$,1,"beq $0 $t0 OPPE_NEG_%llu",labelCounter);
		PUSH_BACK($$,1,"li $t0 0");
		PUSH_BACK($$,1,"j OPPE_NEG_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"OPPE_NEG_%llu :",labelCounter);
		PUSH_BACK($$,1,"li $t0 1");
		PUSH_BACK($$,1,"OPPE_NEG_%llu_FIN :",labelCounter);
		++labelCounter;
	}
// ---1-------------------------------------------------------------- DONE
	| number {
		printf("number -> evaluation\n");
		
		instructionListMalloc(&$$);
		PUSH_BACK($$,1,"li $t0 %s",$1);
	}
// ---1-------------------------------------------------------------- DONE
	| variable_incr	{
		printf("variable_incr -> evaluation\n");
		
		$$ = $1;
	}
	;

//__________________________________________________________________________________

variable_incr :
// -1------------------2--------------------------------------------- DONE TODO check if array
	OPERATOR_INCREMENT variable	{
		printf("OPERATOR_INCREMENT variable -> variable_incr\n");

		instructionListMalloc(&$$);
		switch($2->type){
			case unit :
				if( ((Unit*)$2->data)->init == false ){
					ERROR("La variable '%s' est utilise mais pas initialise !",((Unit*)$2->data)->id); 				
				}
				PUSH_BACK($$,1,"lw $t0 %s",((Unit*)$2->data)->mipsId);
				if(!strcmp($1, "++")){
					PUSH_BACK($$,1,"add $t0 $t0 1");
				}else{
					PUSH_BACK($$,1,"sub $t0 $t0 1");
				}
				PUSH_BACK($$,1,"sw $t0 %s",((Unit*)$2->data)->mipsId);
				break;
			case constUnit :
				ERROR("La variable '%s' a ete declare constante !",((Unit*)$2->data)->id); 				
				break;
			default :
				ERROR("TODO variable OPERATOR_INCREMENT");
		}
	}
// ---1--------2----------------------------------------------------- DONE TODO check if array
	| variable OPERATOR_INCREMENT {
		printf("variable OPERATOR_INCREMENT -> variable_incr\n");
		
		instructionListMalloc(&$$);
		switch($1->type){
			case unit :
				if( ((Unit*)$1->data)->init == false ){
					ERROR("La variable '%s' est utilise mais pas initialise !",((Unit*)$1->data)->id); 				
				}
				PUSH_BACK($$,1,"lw $t0 %s",((Unit*)$1->data)->mipsId);
				if(!strcmp($2, "++")){
					PUSH_BACK($$,1,"add $t0 $t0 1");
				}else{
					PUSH_BACK($$,1,"sub $t0 $t0 1");
				}
				PUSH_BACK($$,1,"sw $t0 %s",((Unit*)$1->data)->mipsId);
				if(!strcmp($2, "++")){
					PUSH_BACK($$,1,"sub $t0 $t0 1");
				}else{
					PUSH_BACK($$,1,"add $t0 $t0 1");
				}
				break;
			case constUnit :
				ERROR("La variable '%s' a ete declare constante !",((ConstUnit*)$1->data)->id); 				
				break;
			default :
				ERROR("TODO variable OPERATOR_INCREMENT");
		}
	}
// ---1-------------------------------------------------------------- DONE TODO check if array
	| variable {
		printf("variable -> variable_incr\n");

		instructionListMalloc(&$$);
		switch($1->type){
			case unit :
				if( ((Unit*)$1->data)->init == false ){
					ERROR("La variable '%s' est utilise mais pas initialise !",((Unit*)$1->data)->id); 				
				}
				PUSH_BACK($$,1,"lw $t0 %s",((Unit*)$1->data)->mipsId);
				break;
			case constUnit :
				PUSH_BACK($$,1,"lw $t0 %s",((ConstUnit*)$1->data)->mipsId);
				break;
			default :
				ERROR("TODO variable");
		}
	}
	;

//__________________________________________________________________________________

number :
// -1---------------------------------------------------------------- DONE
	NUMBER {
		printf("NUMBER -> number\n");
		sprintf($$,"%s",$1);
	}
// ---1-----------------2-------------------------------------------- DONE
	| OPERATOR_ADDITION NUMBER {
		printf("OPERATOR_ADDITION NUMBER -> number\n");
		sprintf($$,"%s%s",$1,$2);
	}
	;

%%//==============================================================================================

void clearProg()
{
	if(outputFile!=NULL)fclose(outputFile);
	if(symbolsTable!=NULL)symbolsTableFree(symbolsTable);
	if(rootTree!=NULL)instructionListFree(rootTree);
}

int main(void)
{
	if(atexit(clearProg) != 0)
    {
        perror("[main] Probleme lors de l'enregistrement ");
        exit(EXIT_FAILURE);
    }

	symbolsTableMalloc(&symbolsTable);
	instructionListMalloc(&rootTree);
	
	yyparse();
	
	outputFile = fopen("output.mips","w");
	instructionListPrintFILE(rootTree,outputFile);	

	return EXIT_SUCCESS;
}

void yyerror (char const *s)
{
	fprintf(stderr,"error : %s at line %d\n",s,yylineno);
	exit(EXIT_FAILURE);
}