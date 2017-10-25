%{

#include <string.h>
#include <stdio.h>

%}

DEFINE            (#define)[ ]
FOR					      (?i:for)
WHILE				      (?i:while)
IF                (?i:if)
ELSE              (?i:else)
RETURN 			      (?i:return)
MAIN				      (main)
PRINTF					(?i:printf)
PRINTI					(?i:printi)
VARIABLE 			    [a-zA-Z_][0-9a-zA-Z_]*
CHIFFRE  			    ([0-9]+[0-9]*)
TYPE				      (void|int|stencil)[ ]
OPERATOR          (\+|-|\/|%)
OPERATOR_STENCIL  ($)
INCREMENT         (\+\+|--)
AFFECT			      (\+=|-=|\*=|\/=|%=|=)
COMPARATOR        (<=|>=|==|!=|>|<|&&|\|\||!)
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
STRING			(\"([^\"\n]|\\(.|\n))*\")
USELESS           [ |\n|\t]
UNKNOW            .

%%

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

{VARIABLE} {
  
  printf("VARIABLE : %s\n",yytext);

}

{CHIFFRE} {

  printf("CHIFFRE : %s\n",yytext);

}

{TYPE} {

	printf("TYPE : %s\n",yytext);

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