%{

#ifdef PRINT
#define TOKEN(t) printf("Token: " #t "\n");
#define NUMBER_TOKEN(t) printf("Number %d Token: " #t "\n", atoi(yytext));
#define FLOAT_TOKEN(t) printf("Float %s Token: " #t "\n", yytext);
#define CHARCON_TOKEN(t) printf("Character %c Token: " #t "\n", yytext[1]);
#define IDENTIFIER_TOKEN(t) printf("Identifier %s Token: " #t "\n", yytext);
#else

int installId(char *id); 
int lookup(char *s);

#define TOKEN(t) return(t);
#define NUMBER_TOKEN(t) yylval.iVal = atoi(yytext); return(t);
#define FLOAT_TOKEN(t) yylval.iVal = installId(yytext); return(t);
#define CHARCON_TOKEN(t) yylval.iVal = yytext[1]; return(t);
#define IDENTIFIER_TOKEN(t) yylval.iVal = installId(yytext); return(t);



/* Declare Symbol Table Type and Array as imported types */
#include <string.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;

#endif
%}

delim            [ \r\n\t]
ws               {delim}*
digit            [0-9]
number           {digit}+
character        [A-Za-z]
string           {character}+
charcon          "'"{character}"'"
identifier       {character}({character}|{digit})*
float   		 {number}"."{number}


%%

{ws}            ;

";"             TOKEN(SEMICOLON)
"+"             TOKEN(PLUS)
"-"             TOKEN(SUBTRACT)
"*"             TOKEN(MULTIPLY)
"/"             TOKEN(DIVIDE)
"("             TOKEN(BRA)
")"             TOKEN(KET)

":"             TOKEN(COLON)
","             TOKEN(COMMA)
"."             TOKEN(FLOATING_POINT_END_PROGRAM)
"->"            TOKEN(ASSIGN)
"="             TOKEN(EQUALS)
"<>"            TOKEN(NOT_EQUALS_TO)
"<"             TOKEN(LESS_THAN)
">"             TOKEN(GREATER_THAN)
"<="            TOKEN(LESS_THAN_OR_EQUALS_TO)
">="            TOKEN(GREATER_THAN_OR_EQUALS_TO)
ENDP          TOKEN(ENDP)
DECLARATIONS  TOKEN(DECLARATIONS)
CODE          TOKEN(CODE)

OF            TOKEN(OF)
TYPE          TOKEN(TYPE)

CHARACTER     TOKEN(CHARACTER)
INTEGER       TOKEN(INTEGER)
REAL          TOKEN(REAL)

IF            TOKEN(IF)
THEN          TOKEN(THEN)
ELSE          TOKEN(ELSE)
ENDIF         TOKEN(ENDIF)

DO            TOKEN(DO)
WHILE         TOKEN(WHILE)
ENDDO         TOKEN(ENDDO)
ENDWHILE	  TOKEN(ENDWHILE)
FOR           TOKEN(FOR)
IS            TOKEN(IS)
BY            TOKEN(BY)
TO            TOKEN(TO)
ENDFOR        TOKEN(ENDFOR)

WRITE         TOKEN(WRITE)
NEWLINE       TOKEN(NEWLINE)

READ          TOKEN(READ)

NOT           TOKEN(NOT)
AND           TOKEN(AND)
OR            TOKEN(OR)

{identifier}    IDENTIFIER_TOKEN(IDENTIFIER)
{number}        NUMBER_TOKEN(NUMBER)
{float}			FLOAT_TOKEN(FLOAT)
{charcon}       CHARCON_TOKEN(CHARCON)
. 				printf("Error: Unexpected symbol in lexical analyser: %s(%d)\n", yytext, yytext[0]);
%%
#ifndef PRINT

/* Here is the code for the library of symbol table routines */

/* code for a simple symbol table, which is an array of pointers to
   structs, each of which contains an identifier.
*/


SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}


/* Look up an identifier in the symbol table, if its there return
   its index.  If its not there, put it in the end position,
   as long as the table isn't full, and return its index.
*/

int installId(char *id) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
        return (index);
    }
    else if (currentSymTabSize >= SYMTABSIZE) 
          /* SYMTAB is full */
          return (NOTHING) ;
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
       return(currentSymTabSize++);
    }
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);    
}

#endif
