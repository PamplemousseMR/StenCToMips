%start programme

%union {

  char* String;
  
}

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
%token<String> ID           
%token<String> CHIFFRE      
%token<String> TYPE       
%token<String> STENCIL      
%token<String> OPERATOR        
%token<String> OPERATOR_STENCIL      
%token<String> INCREMENT        
%token<String> EQUALS        
%token<String> AFFECT        
%token<String> COMPARATOR   
%token<String> LBRA        
%token<String> RBRA        
%token<String> LHOO        
%token<String> RHOO        
%token<String> LEMB        
%token<String> REMB        
%token<String> COMMA        
%token<String> SEMI        
%token<String> STRING     

%type<String> programme           
%type<String> suite_instructions_preprocesseurs           
%type<String> instruction_preprocesseur           
%type<String> suite_fonctions           
%type<String> main           
%type<String> arguments           
%type<String> suite_instructions           
%type<String> ligne           
%type<String> return           
%type<String> variable           
%type<String> hooks           
%type<String> initialisation           
%type<String> suite_variable_init           
%type<String> variable_init           
%type<String> affectation           
%type<String> for           
%type<String> while
%type<String> if
%type<String> else
%type<String> evaluation           
%type<String> evaluation_valeur           

%{
	#include <stdio.h>
	#include <stdlib.h>

	#define KNRM  "\x1B[0m"
	#define KRED  "\x1B[31m"
	#define KGRN  "\x1B[32m"
	#define KYEL  "\x1B[33m"
	#define KBLU  "\x1B[34m"
	#define KMAG  "\x1B[35m"
	#define KCYN  "\x1B[36m"
	#define KWHT  "\x1B[37m"
	
	int yylex();
	void yyerror (char const *s);
%}

%% //==============================================================================================

//-------------------------------------------------------------------------------------------------
//				La structure d'un programme 
//-------------------------------------------------------------------------------------------------

programme : suite_instructions_preprocesseurs suite_fonctions { printf("suite_instructions_preprocesseurs suite_fonctions -> programme\n"); }; //checked

suite_instructions_preprocesseurs : instruction_preprocesseur suite_instructions_preprocesseurs { printf("instruction_preprocesseur suite_instructions_preprocesseurs -> suite_instructions_preprocesseurs\n"); } //checked
								    | {}
								    ;
									
instruction_preprocesseur : DEFINE ID CHIFFRE ENDLINE		{ printf("DEFINE ID CHIFFRE ENDLINE -> instruction_preprocesseur\n"); }; //checked

suite_fonctions : main										{ printf("main -> suite_fonctions\n"); } ; 								//checked

main : TYPE MAIN LBRA arguments RBRA LEMB suite_instructions REMB { printf("TYPE MAIN LBRA arguments RBRA LEMB suite_instructions REMB -> main\n"); }; //checked

arguments : {};																														//TODO

suite_instructions : ligne suite_instructions				{ printf("ligne suite_instructions  -> suite_instructions\n"); }		//checked
					| ligne									{ printf("ligne -> suite_instructions\n"); }							//checked
					;

ligne : for 												{ printf("for -> ligne\n"); }											//checked
		| while												{ printf("while -> ligne\n"); }											//checked
		| if 												{ printf("if -> ligne\n"); }											//checked
		| LEMB suite_instructions REMB 						{ printf("LEMB suite_instructions REMB -> ligne\n"); }					//checked
		| initialisation SEMI								{ printf("initialisation SEMI -> ligne\n"); }							//checked
		| affectation SEMI									{ printf("affectation SEMI -> ligne\n"); }								//checked
		| return SEMI										{ printf("return SEMI -> ligne\n"); }									//checked
		| evaluation SEMI									{ printf("evaluation SEMI -> ligne\n"); }								//checked
		;

return : RETURN evaluation									{ printf("RETURN evaluation -> return : %s%s %s%s\n", KYEL, $1, $2, KNRM); };							//checked

//-------------------------------------------------------------------------------------------------
//				Les variables
//-------------------------------------------------------------------------------------------------

variable : 	ID 	hooks 										{ printf("ID hooks -> variable\n"); };									//checked

hooks : LHOO evaluation RHOO hooks							{ printf("LHOO evaluation RHOO -> hooks\n"); }							//checked
		| {}
		;
		
initialisation : TYPE suite_variable_init 					{ printf("TYPE suite_variable_init -> initialisation\n"); };			//checked

suite_variable_init : variable_init COMMA suite_variable_init {printf("variable_init COMA suite_variable_init -> suite_variable_init\n"); } //checked
					  | variable_init						{ printf("variable_init -> suite_variable_init\n"); }					//checked
					  ;
					  
variable_init : variable EQUALS evaluation					{ printf("variable EQUALS evaluation -> variable_init\n"); }			//checked
				| variable									{ printf("variable -> variable_init\n"); }								//checked
				;

affectation : variable EQUALS evaluation					{ printf("variable EQUALS evaluation -> affectation\n"); }				//checked
			  | variable AFFECT evaluation					{ printf("variable AFFECT evaluation -> affectation\n"); }				//checked
			  ;

//-------------------------------------------------------------------------------------------------
//				Les instructions conditionnelles
//-------------------------------------------------------------------------------------------------

for : FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne { printf("FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne -> for\n"); };					//not finish
	
while : WHILE LBRA evaluation RBRA ligne 					{ printf("WHILE LBRA evaluation RBA ligne -> while\n"); };				//checked

if : IF LBRA evaluation RBRA ligne else						{ printf("IF LBRA evaluation RBRA ligne else -> if\n"); };				//checked

else : ELSE ligne											{ printf("ELSE ligne -> else\n"); }										//checked
	   | {}
	   ;


//-------------------------------------------------------------------------------------------------
//				Le retour des valeurs 
//-------------------------------------------------------------------------------------------------

evaluation : 	LBRA evaluation RBRA  						{ printf("LBRA evaluation RBRA -> evaluation : %s%s %s %s%s\n", KGRN, $1, $2, $3, KNRM); }						//checked
				| PRINTF LBRA STRING RBRA  					{ printf("PRINTF LBRA STRING RBRA -> evaluation : %s%s %s %s %s%s\n", KGRN, $1, $2, $3, $4, KNRM); }					//checked
				| PRINTI LBRA evaluation RBRA  				{ printf("PRINTI LBRA evaluation RBRA -> evaluation : %s%s %s %s %s%s\n", KGRN, $1, $2, $3, $4, KNRM); }				//checked
				| INCREMENT evaluation  					{ printf("INCREMENT evaluation -> evaluation : %s%s %s%s\n", KGRN, $1, $2, KNRM); }						//checked
				| CHIFFRE 									{ printf("CHIFFRE -> evaluation : %s%s%s\n", KGRN, $1, KNRM); }									//checked
				| evaluation_valeur COMPARATOR evaluation  	{ printf("evaluation_valeur COMPARATOR evaluation  -> evaluation : %s%s %s %s%s\n", KGRN, $1, $2, $3, KNRM); }	//checked ugly
				| evaluation_valeur OPERATOR evaluation  	{ printf("evaluation_valeur OPERATOR evaluation -> evaluation : %s%s %s %s%s\n", KGRN, $1, $2, $3, KNRM); }	//checked ugly
				| evaluation_valeur INCREMENT  				{ printf("evaluation_valeur INCREMENT -> evaluation : %s%s %s%s\n", KGRN, $1, $2, KNRM); }				//checked ugly
				| variable									{ printf("variable -> evaluation : %s%s%s\n", KGRN, $1, KNRM); }									//checked ugly
				;

evaluation_valeur : evaluation ;																									//checked ugly

%% //==============================================================================================

int main(void) 
{
  yyparse();
  return 0;
}