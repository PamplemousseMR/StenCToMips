%{

#include <string.h>
#include <stdio.h>

#define STATE_NORMAL 0
#define STATE_DEFINE 1

int state = STATE_NORMAL;

%}

DEFINE            (#define)[ ]
ENDLINE           (\n)
FOR					      (for)
WHILE				      (while)
IF                (if)
ELSE              (else)
RETURN 			      (return)
MAIN				      (main)
PRINTF					  (printf)
PRINTI					  (printi)
ID      			    [a-zA-Z_][0-9a-zA-Z_]*
CHIFFRE  			    ([0-9]+[0-9]*)
TYPE				      (void|int)[ ]
STENCIL           (stencil)[ ]
OPERATOR          (\+|-|\/|%)
OPERATOR_STENCIL  ($)
INCREMENT         (\+\+|--)
EQUALS            (=)
AFFECT			      (\+=|-=|\*=|\/=|%=)
COMPARATOR        (<=|>=|==|!=|>|<)
LBRA				      (\()
RBRA 				      (\))
LHOO				      (\[)
RHOO				      (\])
LEMB				      (\{)
REMB				      (\})
COMMA				      (\,)
SEMI				      (\;)
COM_SINGLE        (\/\/[^\n]*)
COM_MULTI         (\/\*(.|\n)*\*\/)
STRING			      (\"([^\"\n]|\\(.|\n))*\")
USELESS           [ |\t]
UNKNOW            .

%%

{DEFINE} {

  state = STATE_DEFINE;
  printf("DEFINE : %s\n",yytext);

}

{ENDLINE} {

  if(state == STATE_DEFINE)
  {
    printf("ENDLINE : %s\n",yytext);
    state = STATE_NORMAL;
  }

}

{FOR} {

	printf("FOR : %s\n",yytext);

}

{WHILE} {

	printf("WHILE : %s\n",yytext);

}

{IF} {

  printf("IF : %s\n",yytext);

}

{RETURN} {

  printf("RETURN : %s\n",yytext);

}

{MAIN} {

  printf("MAIN : %s\n",yytext);

}

{PRINTF} {
	
	printf("PRINTF : %s\n",yytext);
	
}

{PRINTI} {
	
	printf("PRINTI : %s\n",yytext);
	
}

{ID} {
  
  printf("ID : %s\n",yytext);

}

{CHIFFRE} {

  printf("CHIFFRE : %s\n",yytext);

}

{TYPE} {

	printf("TYPE : %s\n",yytext);

}

{STENCIL} {

  printf("STENCIL : %s\n",yytext);

}

{OPERATOR} {
  
  printf("OPERATOR : %s\n",yytext);

}

{OPERATOR_STENCIL} {
  
  printf("OPERATOR_STENCIL : %s\n",yytext);

}

{INCREMENT} {
  
  printf("INCREMENT : %s\n",yytext);

}

{EQUALS} {
  
  printf("EQUALS : %s\n",yytext);

}

{AFFECT} {
  
  printf("AFFECT : %s\n",yytext);

}

{COMPARATOR} {
  
  printf("COMPARATOR : %s\n",yytext);

}

{LBRA} {
  
  printf("LBRA : %s\n",yytext);

}

{RBRA} {
  
  printf("RBRA : %s\n",yytext);

}

{LHOO} {
  
  printf("LHOO : %s\n",yytext);

}

{RHOO} {
  
  printf("RHOO : %s\n",yytext);

}

{LEMB} {
  
  printf("LEMB : %s\n",yytext);

}

{REMB} {
  
  printf("RBRA : %s\n",yytext);

}

{COMMA} {
  
  printf("COMMA : %s\n",yytext);

}

{SEMI} {
  
  printf("SEMI : %s\n",yytext);

}

{COM_SINGLE} {

  printf("COM_SINGLE : %s\n",yytext);

}

{COM_MULTI} {

  printf("COM_MULTI : %s\n",yytext);

}

{STRING} {
	
	printf("STRING : %s\n",yytext);
	
}

{USELESS} {}

{UNKNOW} {
  
  printf("\x1b[31mUNKNOW : \x1b[0m%s\n",yytext);
}

%%

int main()
{

  yylex();

  return 1;
  
}

int yywrap()
{

  return 1;
  
}