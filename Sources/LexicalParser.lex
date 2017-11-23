%{

#include <string.h>
#include <stdio.h>

#include "SyntaxParser.h"

#ifdef DEBUG
#define printf(args...) printf(args);
#else
#define printf(...)
#endif

#define STATE_NORMAL 0
#define STATE_DEFINE 1

int state = STATE_NORMAL;

%}

%option yylineno

DEFINE				(#define)[ ]
ENDLINE				(\n)
FOR					(for)
WHILE				(while)
IF					(if)
ELSE				(else)
RETURN				(return)
MAIN				(main)
PRINTF				(printf)
PRINTI				(printi)
STENCIL				(stencil)
TYPE				(int)
ID					[a-zA-Z_][0-9a-zA-Z_]*
NUMBER				([0-9]+)
OPERATOR_NEGATION	(!)
OPERATOR_INCREMENT	(\+\+|--)
OPERATOR_MULTI		(\/|\*|%)
OPERATOR_ADDITION	(\+|-)
COMPARATOR_SUPREMACY (<=|>=|>|<)
COMPARATOR_EQUALITY (==|!=)
COMPARATOR_AND		(&&)
COMPARATOR_OR		(\|\|)
EQUALS				(=)
AFFECT				(\+=|-=|\*=|\/=|%=)
OPERATOR_STENCIL	($)
LBRA				(\()
RBRA				(\))
LHOO				(\[)
RHOO				(\])
LEMB				(\{)
REMB				(\})
COMMA				(\,)
SEMI				(\;)
COM_SINGLE			(\/\/[^\n]*)
COM_MULTI			(\/\*(.|\n)*\*\/)
STRING				(\"([^\"\n]|\\(.|\n))*\")
USELESS				[ |\t]
UNKNOW				.

%%

{DEFINE} {

	state = STATE_DEFINE;
	printf("\t\tDEFINE : %s\n",yytext);
	yylval.String = strdup(yytext);
	return DEFINE;
}

{ENDLINE} {

	if(state == STATE_DEFINE)
	{
		printf("\t\tENDLINE : %s\n",yytext);
		state = STATE_NORMAL;
		yylval.String = strdup(yytext);
		return ENDLINE;
	}

}

{FOR} {

	printf("\t\tFOR : %s\n",yytext);
	yylval.String = strdup(yytext);
	return FOR;

}

{WHILE} {

	printf("\t\tWHILE : %s\n",yytext);
	yylval.String = strdup(yytext);
	return WHILE;

}

{IF} {

	printf("\t\tIF : %s\n",yytext);
	yylval.String = strdup(yytext);
	return IF;

}

{ELSE} {
	
	printf("\t\tELSE : %s", yytext)
	yylval.String = strdup(yytext);
	return ELSE;

}

{RETURN} {

	printf("\t\tRETURN : %s\n",yytext);
	yylval.String = strdup(yytext);
	return RETURN;

}

{MAIN} {

	printf("\t\tMAIN : %s\n",yytext);
	yylval.String = strdup(yytext);
	return MAIN;

}

{PRINTF} {
	
	printf("\t\tPRINTF : %s\n",yytext);
	yylval.String = strdup(yytext);
	return PRINTF;
	
}

{PRINTI} {
	
	printf("\t\tPRINTI : %s\n",yytext);
	yylval.String = strdup(yytext);
	return PRINTI;
	
}

{STENCIL} {

	printf("\t\tSTENCIL : %s\n",yytext);
	yylval.String = strdup(yytext);
	return STENCIL;

}

{TYPE} {

	printf("\t\tTYPE : %s\n",yytext);
	yylval.String = strdup(yytext);
	return TYPE;

}

{ID} {
	
	printf("\t\tID : %s\n",yytext);
	yylval.String = strdup(yytext);
	return ID;

}

{NUMBER} {

	printf("\t\tNUMBER : %s\n",yytext);
	yylval.String = strdup(yytext);
	return NUMBER;

}

{OPERATOR_NEGATION} {
	
	printf("\t\tOPERATOR_NEGATION : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_NEGATION;

}

{OPERATOR_INCREMENT} {
	
	printf("\t\tOPERATOR_INCREMENT : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_INCREMENT;

}

{OPERATOR_MULTI} {
	
	printf("\t\tOPERATOR_MULTI : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_MULTI;

}

{OPERATOR_ADDITION} {
	
	printf("\t\tOPERATOR_ADDITION : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_ADDITION;

}

{COMPARATOR_SUPREMACY} {
	
	printf("\t\tCOMPARATOR_SUPREMACY : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMPARATOR_SUPREMACY;

}

{COMPARATOR_EQUALITY} {
	
	printf("\t\tCOMPARATOR_EQUALITY : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMPARATOR_EQUALITY;

}

{COMPARATOR_AND} {
	
	printf("\t\tCOMPARATOR_AND : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMPARATOR_AND;

}

{COMPARATOR_OR} {
	
	printf("\t\tCOMPARATOR_OR : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMPARATOR_OR;

}

{EQUALS} {
	
	printf("\t\tEQUALS : %s\n",yytext);
	yylval.String = strdup(yytext);
	return EQUALS;

}

{AFFECT} {
	
	printf("\t\tAFFECT : %s\n",yytext);
	yylval.String = strdup(yytext);
	return AFFECT;

}

{OPERATOR_STENCIL} {
	
	printf("\t\tOPERATOR_STENCIL : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_STENCIL;

}


{LBRA} {

	printf("\t\tLBRA : %s\n",yytext);
	yylval.String = strdup(yytext);
	return LBRA;

}

{RBRA} {
	
	printf("\t\tRBRA : %s\n",yytext);
	yylval.String = strdup(yytext);
	return RBRA;

}

{LHOO} {
	
	printf("\t\tLHOO : %s\n",yytext);
	yylval.String = strdup(yytext);
	return LHOO;

}

{RHOO} {
	
	printf("\t\tRHOO : %s\n",yytext);
	yylval.String = strdup(yytext);
	return RHOO;

}

{LEMB} {
	
	printf("\t\tLEMB : %s\n",yytext);
	yylval.String = strdup(yytext);
	return LEMB;

}

{REMB} {
	
	printf("\t\tREMB : %s\n",yytext);
	yylval.String = strdup(yytext);
	return REMB;

}

{COMMA} {
	
	printf("\t\tCOMMA : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMMA;

}

{SEMI} {
	
	printf("\t\tSEMI : %s\n",yytext);
	yylval.String = strdup(yytext);
	return SEMI;

}

{COM_SINGLE} {

	printf("\t\tCOM_SINGLE : %s\n",yytext);

}

{COM_MULTI} {

	printf("\t\tCOM_MULTI : %s\n",yytext);

}

{STRING} {
	
	printf("\t\tSTRING : %s\n",yytext);
	yylval.String = strdup(yytext);
	return STRING;
	
}

{USELESS} {}

{UNKNOW} {
	
	fprintf(stderr,"\t\t\x1b[31mUNKNOW : \x1b[0m%s at line %d\n",yytext,yylineno);

}

%%

int yywrap()
{

	return 1;
	
}