/* declare some standard headers to be used to import declarations
   and libraries into the parser. */
%{

#include <stdio.h>
#include <stdlib.h>

/* 
   Some constants.
*/

  /* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2
/*#define DEBUG*/
	enum ParseTreeNodeType { PROGRAM, BLOCK, ID_LIST, SINGLE_DECLARATION, DECLARATION_BLOCK, 
						   STATEMENT_LIST, STATEMENT, ASSIGNMENT_STATEMENT, IF_STATEMENT,
						   FOR_STATEMENT, DO_STATEMENT, WHILE_STATEMENT, WRITE_STATEMENT, 
						   NEWLINE_STATEMENT, READ_STATEMENT, OUTPUT_LIST, COMPARATOR, 
						   EXPRESSION, TERM, ID_VALUE, Con_VALUE, exp_VALUE, CONSTANT,
						   NUMBER_CONSTANT, MINUS_NUMBER_CONSTANT, FLOAT_CONSTANT, 
						   MINUS_FLOAT_CONSTANT, CONDITIONAL, NOT_CONDITIONAL,
						   OR_CONDITIONAL, AND_CONDITIONAL, TYPE_Node, CHARACTER_CONSTANT
						   } ; 
						  /* Add more types here, as more nodes
                                           added to tree */
										  
	char *NodeName[] = 	{	"PROGRAM", "BLOCK", "ID_LIST", "SINGLE_DECLARATION", "DECLARATION_BLOCK", 
							"STATEMENT_LIST", "STATEMENT", "ASSIGNMENT_STATEMENT", "IF_STATEMENT", 
							"FOR_STATEMENT", "DO_STATEMENT", "WHILE_STATEMENT", "WRITE_STATEMENT", 
							"NEWLINE_STATEMENT", "READ_STATEMENT", "OUTPUT_LIST", "COMPARATOR", 
							"EXPRESSION", "TERM", "ID_VALUE", "Con_VALUE", "exp_VALUE", "CONSTANT", 
							"NUMBER_CONSTANT", "MINUS_NUMBER_CONSTANT", "FLOAT_CONSTANT",
							"MINUS_FLOAT_CONSTANT", "CONDITIONAL", "NOT_CONDITIONAL",
							"OR_CONDITIONAL", "AND_CONDITIONAL", "TYPE_Node", "CHARACTER_CONSTANT"
						} ;
										   
										   
#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

/* ------------- parse tree definition --------------------------- */

struct treeNode 
{
	int  item;
	int  nodeIdentifier;
	struct treeNode *first;
	struct treeNode *second;
	struct treeNode *third;
};

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE        *TERNARY_TREE;

/* ------------- forward declarations --------------------------- */

TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);
#ifdef DEBUG
	void PrintTree(TERNARY_TREE, int);
#endif
	void getType(TERNARY_TREE);
	void writeCode(TERNARY_TREE);
/* ------------- symbol table definition --------------------------- */

struct symTabNode 
{
	char identifier[IDLENGTH];
	char tempType;
};

char tempType2;
int writing = 0;
int forLoop = 0;
typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE        *SYMTABNODEPTR;

SYMTABNODEPTR  symTab[SYMTABSIZE]; 

int currentSymTabSize = 0;

%}

/****************/
/* Start symbol */
/****************/

%start  program

/**********************/
/* Action value types */
/**********************/

%union 
{
	int iVal;
	TERNARY_TREE  tVal;
}


%{
	int yylex();
	int yyerror(char *);
%}

%token		SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE 
			BRA KET COLON COMMA FLOATING_POINT_END_PROGRAM ASSIGN EQUALS
			LESS_THAN GREATER_THAN LESS_THAN_OR_EQUALS_TO GREATER_THAN_OR_EQUALS_TO
			END DECLARATIONS CODE OF TYPE CHARACTER INTEGER REAL 
			IF THEN ELSE ENDIF DO WHILE ENDDO FOR IS BY TO ENDFOR WRITE NEWLINE
			READ NOT AND OR ENDP ENDWHILE NOT_EQUALS_TO

%token<iVal>NUMBER FLOAT CHARCON IDENTIFIER

%type<tVal> program block id_list single_declaration declaration_block 
			type statement_list statement assignment_statement if_statement
			do_statement while_statement write_statement read_statement
			output_list comparator expression term value constant
	   	    number_constant for_statement conditional
%%

program : IDENTIFIER COLON block ENDP IDENTIFIER FLOATING_POINT_END_PROGRAM
	{
		TERNARY_TREE ParseTree;
		ParseTree = create_node($1, PROGRAM, $3,NULL,
					create_node($5, PROGRAM, NULL, NULL, NULL));
		#ifdef DEBUG
			PrintTree(ParseTree, 0);
		#endif
		getType(ParseTree);
		writeCode(ParseTree);
	}
	;
block : DECLARATIONS declaration_block CODE statement_list
			{
				$$ = create_node(NOTHING, BLOCK, $2, $4, NULL);
			}
			|CODE statement_list
			{
				$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL)
			}
	;
id_list : IDENTIFIER 
			{
				$$ = create_node($1, ID_LIST, NULL, NULL, NULL);
			}
			|IDENTIFIER COMMA id_list
			{
				$$ = create_node($1, ID_LIST, $3, NULL, NULL);
			}
	;
single_declaration : id_list OF TYPE type SEMICOLON
			{
				$$ = create_node(NOTHING, SINGLE_DECLARATION, $1, $4, NULL);
			}
	;
declaration_block : single_declaration
			{
				$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, NULL, NULL);
			}
		    |single_declaration declaration_block
			{
				$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $2, NULL);
			}
	;
type : CHARACTER 
			{
				$$ = create_node(CHARACTER, TYPE_Node, NULL, NULL, NULL);
			}
			|INTEGER 
			{
				$$ = create_node(INTEGER, TYPE_Node, NULL, NULL, NULL);
			}
			|REAL
			{
				$$ = create_node(REAL, TYPE_Node, NULL, NULL, NULL);
			}
	;
statement_list : statement
			{
				$$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL);
			}
			| statement SEMICOLON statement_list
			{
				$$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL);
			}
	;
statement : assignment_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| if_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| do_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| while_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| for_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| write_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}	
			| read_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
	;
assignment_statement : expression ASSIGN IDENTIFIER
			{
				$$ = create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL);
			}
	;
if_statement : IF conditional THEN statement_list ENDIF 
			{
				$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL);
			}
			|
			IF conditional THEN statement_list ELSE statement_list ENDIF
			{
				$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6);
			}
	;
do_statement : DO statement_list WHILE conditional ENDDO
			{
				$$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL)
			}
	;
while_statement : WHILE conditional DO statement_list ENDWHILE
			{
				$$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL)
			}	
	;
for_statement : FOR IDENTIFIER IS expression BY expression TO expression 
                                    DO statement_list ENDFOR
			{
				$$ = create_node($2, FOR_STATEMENT, $4, $6,
					 create_node(NOTHING, FOR_STATEMENT, $8, $10, NULL))
			}
	;
write_statement : NEWLINE 
			{
				$$ = create_node(NOTHING, NEWLINE_STATEMENT,NULL,NULL,NULL);
			}
			|WRITE BRA output_list KET
			{
				$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);
			}
	;
read_statement : READ BRA IDENTIFIER KET
			{
				$$ = create_node($3, READ_STATEMENT, NULL,NULL,NULL);
			}
	;
output_list : value
			{
				$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL);
			}
			| output_list COMMA value
			{
				$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL);
			}
	;	
conditional : expression comparator expression
			{
				$$ = create_node(NOTHING, CONDITIONAL, $1, $2, $3);
			}
			|expression comparator expression AND conditional
			{
				$$ = create_node(NOTHING, AND_CONDITIONAL, $1, $2,
					 create_node(NOTHING, AND_CONDITIONAL, $3, $5, NULL));
			}
			|expression comparator expression OR conditional
			{
				$$ = create_node(NOTHING, OR_CONDITIONAL, $1, $2,
					 create_node(NOTHING, OR_CONDITIONAL, $3, $5, NULL));
			}
			|NOT conditional
			{
				$$ = create_node(NOTHING, NOT_CONDITIONAL, $2, NULL, NULL);
			}
	;		
comparator : EQUALS 
			{
				$$ = create_node(EQUALS, COMPARATOR, NULL, NULL, NULL);
			}
			| NOT_EQUALS_TO
			{
				$$ = create_node(NOT_EQUALS_TO, COMPARATOR, NULL, NULL, NULL);
			}
			| LESS_THAN 
			{
				$$ = create_node(LESS_THAN, COMPARATOR, NULL, NULL, NULL);
			}
			| GREATER_THAN
			{
				$$ = create_node(GREATER_THAN, COMPARATOR, NULL, NULL, NULL);
			}
			| LESS_THAN_OR_EQUALS_TO
			{
				$$ = create_node(LESS_THAN_OR_EQUALS_TO, COMPARATOR, NULL, NULL, NULL);
			}
			| GREATER_THAN_OR_EQUALS_TO
			{
				$$ = create_node(GREATER_THAN_OR_EQUALS_TO, COMPARATOR, NULL, NULL, NULL);
			}
	;
expression : term
			{
				$$ = create_node(NOTHING,EXPRESSION, $1, NULL, NULL);
			}
			|term PLUS expression 
			{
				$$ = create_node(PLUS ,EXPRESSION, $1, $3, NULL);
			}
			|term SUBTRACT expression
			{
				$$ = create_node(SUBTRACT, EXPRESSION, $1, $3, NULL);
			}
	;
term : value
			{
				$$ = create_node(NOTHING, TERM, $1, NULL, NULL);
			}
			| value MULTIPLY term 
			{
				$$ = create_node(MULTIPLY, TERM, $1, $3, NULL);
			}
			| value DIVIDE term
			{
				$$ = create_node(DIVIDE, TERM, $1, $3, NULL);
			}
	;
value : IDENTIFIER
			{
				$$ = create_node($1, ID_VALUE, NULL, NULL, NULL);
			}
			| constant 
			{
				$$ = create_node(NOTHING, Con_VALUE, $1, NULL, NULL);
			}
			| BRA expression KET
			{
				$$ = create_node(NOTHING, exp_VALUE, $2, NULL, NULL);
			}
	;
constant : number_constant 
			{
				$$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL);
			}
			|CHARCON
			{
				$$ = create_node($1, CHARACTER_CONSTANT, NULL, NULL, NULL);
			}
	;
number_constant : NUMBER
			{
				$$ = create_node($1, NUMBER_CONSTANT, NULL, NULL, NULL);
			}
			|SUBTRACT NUMBER
			{
				$$ = create_node($2, MINUS_NUMBER_CONSTANT, NULL, NULL, NULL);
			}
			|FLOAT
			{
				$$ = create_node($1, FLOAT_CONSTANT, NULL, NULL, NULL);
			}
			|SUBTRACT FLOAT
			{
				$$ = create_node($2, MINUS_FLOAT_CONSTANT, NULL, NULL, NULL);
			}
	;

%%
/* Code for routines for managing the Parse Tree */

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
	return (t);
}
/*Create getType this will traverse a parse tree and look for conValue Expvalue and IDValue and then call the writeCode method where the code inside those cases will do something.*/
void getType(TERNARY_TREE t)
{
	if (t == NULL)
	{
		return;
	}
	
	switch(t->nodeIdentifier)
	{
		case(CONSTANT):
			printf("");
			return;
		case(MINUS_FLOAT_CONSTANT):
			printf("minus float");
			return;
		
		case(FLOAT_CONSTANT):

			printf("%s ", symTab[t->item]->identifier);
			return;
		
		case(NUMBER_CONSTANT):
			printf("Number");
			return;
		
		case(MINUS_NUMBER_CONSTANT):
			printf("Minus NUMBER");
			return;		

	}
	getType(t->first);
	getType(t->second);
	getType(t->third);
}


/* Put other auxiliary functions here */
void writeCode(TERNARY_TREE t)
{
			
	if (t == NULL)
	{
		return;
	}
	
	switch(t->nodeIdentifier)
	{
		case (PROGRAM):
			printf("#include <stdio.h>\n\n");
			printf("int main(void) \n{\n");
			writeCode(t->first);
			printf("\n}\n");
			return;
		
		case (BLOCK):

			writeCode(t->first);
			printf("\n");
			writeCode(t->second);
			return;
		
		
		case (ID_LIST):
			if(t->item >= 0 && t->item < SYMTABSIZE)
			{
				printf("%s", symTab[t->item]->identifier);
				symTab[t->item]->tempType = tempType2;
			}
			else
			{
				printf("Unknown IDENTIFIER: %d", t->item);
			}
			if (t->first) 
			{
				printf(",");
				writeCode(t->first);
			}
			return;
		
		case (SINGLE_DECLARATION):
			writeCode(t->second);
			writeCode(t->first);
			printf(";");
			return;
		
		case (DECLARATION_BLOCK):
			writeCode(t->first);
			writeCode(t->second);
			return;

		
		case (TYPE_Node):
			if (t->item == CHARACTER)
			{
				printf("\nchar ");
				tempType2 = 'C';
				break;
			}
			else if (t->item == INTEGER)
			{
				printf("\nint ");
				tempType2 = 'I';
				break;
			}
			else if (t->item == REAL)
			{
				printf("\nfloat ");
				tempType2 = 'R';
				break;
			}
			return;
			
		
		case (ASSIGNMENT_STATEMENT):
			if(t->item >= 0 && t->item < SYMTABSIZE)
			{
				printf("%s", symTab[t->item]->identifier);
			}
			else
			{
				printf("Unknown IDENTIFIER: %d", t->item);
			}
			printf(" = ");
			writeCode(t->first);
			printf(";");
			printf("\n");
			return;
		
		case (IF_STATEMENT):
			printf("if (");
			writeCode(t->first);
			printf(")\n{");
			writeCode(t->second);
			printf("}\n");
			if(t->third)
			{
				printf("else\n{");
				writeCode(t->third);
				printf("}\n");
			}
			return;
		
		case (DO_STATEMENT):
			printf("do\n{");
			writeCode(t->first);
			printf("} while(");
			writeCode(t->second);
			printf(");\n");
			return;
		
		case (WHILE_STATEMENT):
			printf("while (");
			writeCode(t->first);
			printf(") \n{\n");
			writeCode(t->second);
			printf("\n}\n");
			return;
		
		case (FOR_STATEMENT):
			if (forLoop == 0)
			{
				printf("register int _by, _sign;");
			}
			forLoop = 1;
			printf("for (");
			if(t->item >= 0 && t->item < SYMTABSIZE)
			{
				printf("%s", symTab[t->item]->identifier);
			}
			else
			{
				printf("Unknown IDENTIFIER: %d", t->item);
			}
			printf(" = ");
			writeCode(t->first);
			printf("; ");
			printf("_by = ");
			writeCode(t->second);
			printf(", ");
			printf("_sign=(_by == 0 ? 1 : _by/abs(_by)), ");
			printf("(%s-(", symTab[t->item]->identifier);
			writeCode(t->third->first);
			printf("))");
			printf("*_sign <= 0 ;");
			printf("%s", symTab[t->item]->identifier);
			printf("+= _by");
			printf(")\n{");
			writeCode(t->third->second);
			printf("\n}\n");
			return;
		
		case (WRITE_STATEMENT):	
			writing = 1;
			if(t->first)
			{			
				printf("\nprintf(");
				writeCode(t->first);
				printf(");\n");
			}
			writing = 0;
			return;
		
		case (NEWLINE_STATEMENT):
			printf("printf(\"\\n\");\n");
			return;
		
		case (READ_STATEMENT):
			/*printf("scanf(\"%%d\"");*/
			if(t->item >= 0 && t->item < SYMTABSIZE)
			{
				if(symTab[t->item]->tempType == 'C')
				{
					printf("\nscanf(\" %%c\"", symTab[t->item]->tempType);
					printf(",&%s", symTab[t->item]->identifier);
				}
				else if(symTab[t->item]->tempType == 'I')
				{
					printf("\nscanf(\" %%d\"", symTab[t->item]->tempType);
					printf(",&%s", symTab[t->item]->identifier);
				}
				else if(symTab[t->item]->tempType == 'R')
				{
					printf("\nscanf(\" %%f\"", symTab[t->item]->tempType);
					printf(",&%s", symTab[t->item]->identifier);
				}
			}
			else
			{
				printf("Unknown IDENTIFIER: %d", t->item);
			}
			printf(");\n");
			writeCode(t->first);
			return;
			
			
		case (CONDITIONAL):			
			writeCode(t->first);			
			writeCode(t->second);
			writeCode(t->third);
			return;
			
		case (AND_CONDITIONAL):
			writeCode(t->first);
			writeCode(t->second);
			writeCode(t->third->first);
			printf(" && ");
			writeCode(t->third->second);
			return;
		
		case (OR_CONDITIONAL):
			writeCode(t->first);
			writeCode(t->second);
			writeCode(t->third->first);
			printf(" || ");
			writeCode(t->third->second);
			return;
		
		case (NOT_CONDITIONAL):
			printf("!(");
			writeCode(t->first);
			printf(")");
			return;
		
		case (COMPARATOR):
			if(t->item == EQUALS)
				printf("==");
			else if(t->item == NOT_EQUALS_TO)
				printf("!=");
			else if(t->item == LESS_THAN)
				printf("<");
			else if(t->item == GREATER_THAN)
				printf(">");
			else if(t->item == LESS_THAN_OR_EQUALS_TO)
				printf("<=");
			else if(t->item == GREATER_THAN_OR_EQUALS_TO)
				printf(">=");
			return;

		case (EXPRESSION):
			writeCode(t->first);
			if(t->item == PLUS)
			{
				printf("+");
				writeCode(t->second);
			}
			else if(t->item == SUBTRACT)
			{
				printf("-");
				writeCode(t->second);
			}
			
			return;
		
		case(TERM):
			writeCode(t->first);
			if(t->item == MULTIPLY)
			{
				printf("*");
				writeCode(t->second);
			}
			else if(t->item == DIVIDE)
			{
				printf("/");
				writeCode(t->second);
			}
			return;
		
		
		case(ID_VALUE):
			if(writing == 1)
			{
				if(t->item >= 0 && t->item < SYMTABSIZE)
				{
					if(symTab[t->item]->tempType == 'C')
					{
						printf("\"%%c\",", symTab[t->item]->tempType);
						
					}
					else if(symTab[t->item]->tempType == 'I')
					{
						
						printf("\"%%d\",", symTab[t->item]->tempType);
					}
					else if(symTab[t->item]->tempType == 'R')
					{
						printf("\"%%.2f\",", symTab[t->item]->tempType);
					}
					printf("%s ",symTab[t->item]->identifier);
				}
				else
				{
					printf("Unknown IDENTIFIER: %d", t->item);
				}
			}
			else
			{
				if(t->item >= 0 && t->item < SYMTABSIZE)
				{
					printf("%s ",symTab[t->item]->identifier);
				}
				else
				{
					printf("Unknown IDENTIFIER: %d", t->item);
				}
			}
			writing = 0;
			return;
	
		
		/*	
			
		case (OUTPUT_LIST):
			if (t->first)
			{
				writeCode(t->first);
			}
			else if(t->second)
			{
				writeCode(t->first);
				writeCode(t->second);
			}
			return;
		
			case(ID_VALUE):
			if(t->item >= 0 && t->item < SYMTABSIZE)
			{
				printf("%s ",symTab[t->item]->identifier);
			}
			else
			{
				printf("Unknown IDENTIFIER: %d", t->item);
			}
			return;*/
		case(Con_VALUE):
			writeCode(t->first);

			return;
		
		case(exp_VALUE):
		if (writing == 1)
		{
			printf("\"%%d\",");
			writeCode(t->first);
		}
		else
		{
			printf("(");
			writeCode(t->first);
			printf(")");
		}
			return;
		
		case CHARACTER_CONSTANT:
			printf("\"%c\"", t->item);
			return;
		
		case NUMBER_CONSTANT:

			printf("%d", t->item);
			return;
			
		case MINUS_NUMBER_CONSTANT:

			printf("-%d ", t->item);
			return;
			
		case FLOAT_CONSTANT:

			printf("%s ", symTab[t->item]->identifier);
			return;
			
		case MINUS_FLOAT_CONSTANT:

			printf("-%s ", symTab[t->item]->identifier);
			return;

	}
	

	writeCode(t->first);
	writeCode(t->second);
	writeCode(t->third);

}
void PrintTree(TERNARY_TREE t, int indent)
{
int i;
	if (t == NULL) 
	{
		return;
	}
		
	
	for(i = indent; i; i--)
	{
		printf(" ");
	}

	switch(t->nodeIdentifier)
	{
		case PROGRAM:
			printf("Identifier: %s ", symTab[t->item]->identifier);
			break;
			
		case ID_VALUE:
			printf("Identifier: %s ", symTab[t->item]->identifier);
			break;
		
		case ID_LIST:
			printf("Identifier: %s ", symTab[t->item]->identifier);
			break;
		
		case TYPE_Node:
			if (t->item == CHARACTER)
			{
				printf("Character\n");
				break;
			}
			else if (t->item == INTEGER)
			{
				printf("Integer\n");
				break;
			}
			else if (t->item == REAL)
			{
				printf("Real\n");
				break;
			}
			break;
		
		case ASSIGNMENT_STATEMENT:
			printf("Identifier: %s ", symTab[t->item]->identifier);	
			break;
		
		case READ_STATEMENT:
			printf("Read: %s ", symTab[t->item]->identifier);
			break;
			
		case CHARACTER_CONSTANT:
			printf("Character: %c ", t->item);
			break;
		
		case NUMBER_CONSTANT:
			printf("Number: %d ", t->item);
			break;
		
		case MINUS_NUMBER_CONSTANT:
			printf("Minus Number: %d ", t->item);
			break;
		
		case FLOAT_CONSTANT:
			printf("Float: %s ", symTab[t->item]->identifier);
			break;
		
		case MINUS_FLOAT_CONSTANT:
			printf("Minus Float: %s ", symTab[t->item]->identifier);
			break;
		
		
	}
	
	
	if (t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
	{
		printf("Unknown nodeIdentifier: %d\n", t->nodeIdentifier);
	}
	
	else
	{
		printf("%s\n", NodeName[t->nodeIdentifier]);
	}
	
	PrintTree(t->first, indent+3);
	PrintTree(t->second, indent+3);
	PrintTree(t->third, indent+3);
}

#include "lex.yy.c"
