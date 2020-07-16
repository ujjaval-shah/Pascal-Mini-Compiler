%{
#ifdef YYDEBUG
  yydebug = 1;
#endif
#include<stdio.h>
#include<string.h>
#include<stdlib.h>  
#include "calc.h"  /* Contains definition of `symrec'        */
int  yylex(void);
void yyerror (char  *);
int whileStart=0,nextJump=0; /*two separate variables not necessary for this application*/
int elsepart=0, endif=0;
int count=0;
int labelCount=0;
FILE *fp;
struct StmtsNode *final;

char* chrp;
int total_string=0;

int save_string(char *string_read);
void StmtsTrav(stmtsptr ptr);
void StmtTrav(stmtptr ptr);

int save_string(char *string_read){
  chrp = realloc(chrp, 150*(total_string+1));
  sprintf(chrp+150*total_string,"%s",string_read);
  total_string = total_string+1;
  return (total_string-1);
}


%}
%union {
int   val;  /* For returning numbers.                   */
struct symrec  *tptr;   /* For returning symbol-table pointers      */
char c[1000];
char nData[100];
struct StmtNode *stmtptr;
struct StmtsNode *stmtsptr;
}


/* The above will cause a #line directive to come in calc.tab.h.  The #line directive is typically used by program generators to cause error messages to refer to the original source file instead of to the generated program. */

%token <val> NUM        /* Integer   */
%token <val> RELOP TO T_WRITE 
%token <c> STRING
%token T_READ T_INPUT
%token WHILE
%token T_PROGRAM
%token T_EOL T_DIV
%token T_VAR
%token T_COLON
%token T_INTEGER
%token T_BEGIN
%token T_END
%token T_DOT
%token T_IF T_THEN T_ELSE
%token T_ASSIGN T_WHILE T_DO T_FOR
%token <tptr> VAR
%type <c> exp 
%type <calc> routine routine_head var_part var_decl var_decl_list name_list

%type <nData> x
%type <stmtsptr> routine_body stmt_list compound_stmt stmt
%type <stmtptr> assign_stmt while_stmt for_stmt write_stmt if_stmt read_stmt

%right '='
%left '-' '+'
%left '*' '/'


/* Grammar follows */

%%
prog: T_PROGRAM VAR T_EOL routine T_DOT {printf("rule:1 main\n");} ;

routine: routine_head routine_body {printf("rule:2");};

routine_head: var_part {printf("rule:3");};

var_part:   { printf("rule:3BA\n"); }
|   T_VAR var_decl_list   { printf("rule:3BB\n"); };

var_decl_list:   var_decl var_decl_list { printf("rule:4BA\n"); }
|   var_decl    { printf("rule:4BA\n"); };

var_decl:   name_list T_COLON T_INTEGER T_EOL {printf("rule:7 ");};

name_list:   VAR ',' name_list {printf("rule:8A ");}
|   VAR {printf("rule:8B ");} ;

routine_body:   compound_stmt   {printf("rule:9 "); final=$1;} ;

compound_stmt:   T_BEGIN stmt_list T_END {printf("rule:10A "); $$=$2;} ;
stmt_list:   stmt T_EOL {printf("rule:11A "); $$=$1;}
|   stmt T_EOL stmt_list {printf("rule:11B "); $$=(struct StmtsNode *) malloc(sizeof(struct StmtsNode));
   $$->singl=0;$$->leftblk=$1;$$->right=$3; $$->isLeftABlock=1;};

stmt: assign_stmt {printf("rule:12A "); $$=(struct StmtsNode *) malloc(sizeof(struct StmtsNode));
   $$->singl=1;$$->leftstmt=$1; $$->isLeftABlock=0;}
| compound_stmt  {printf("rule:12B ");  $$=$1;}
|	while_stmt  {printf("rule:12C "); $$=(struct StmtsNode *) malloc(sizeof(struct StmtsNode));
   $$->singl=1;$$->leftstmt=$1; $$->isLeftABlock=0;}
|  for_stmt   {printf("rule:12D "); $$=(struct StmtsNode *) malloc(sizeof(struct StmtsNode));
   $$->singl=1;$$->leftstmt=$1; $$->isLeftABlock=0;}
|  write_stmt  {printf("rule:12E "); $$=(struct StmtsNode *) malloc(sizeof(struct StmtsNode));
   $$->singl=1;$$->leftstmt=$1; $$->isLeftABlock=0;}
|  if_stmt   {printf("rule:12E "); $$=(struct StmtsNode *) malloc(sizeof(struct StmtsNode));
   $$->singl=1;$$->leftstmt=$1; $$->isLeftABlock=0;}
|  read_stmt {printf("rule:12E "); $$=(struct StmtsNode *) malloc(sizeof(struct StmtsNode));
   $$->singl=1;$$->leftstmt=$1; $$->isLeftABlock=0;}   
;

read_stmt: T_READ '(' T_INPUT ',' VAR ')' {   
   $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
   $$->statement_type=READ_STATEMENT;
   sprintf($$->bodyCode,"\nli $v0, 5\nsyscall\nmove $t0, $v0\nsw $t0,%s($t8)\n",$5->addr);
}
;

write_stmt: T_WRITE '(' exp ')' {
   $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
   $$->statement_type=WRITE_STATEMENT;
   if($1==1) sprintf($$->bodyCode,"\n%s\nli $v0,1\nmove $a0,$t0\nsyscall\n",$3);
   if($1==2) sprintf($$->bodyCode,"\n%s\nli $v0,1\nmove $a0,$t0\nsyscall\nli $a0,10\nli $v0,11\nsyscall",$3);
   }
|     T_WRITE '(' ')' {
   if($1==2) {
      $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
      $$->statement_type=WRITE_STATEMENT;
      sprintf($$->bodyCode,"\nli $a0,10\nli $v0,11\nsyscall");
   }else{$$=NULL;}}
|  T_WRITE '(' '\'' STRING '\'' ')' {
   printf(" rule write string | ");
   $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
   $$->statement_type=WRITE_STRING_STATE;
   $$->string_used = save_string($4);
   if($1==2) sprintf($$->bodyCode,"\nli $a0,10\nli $v0,11\nsyscall");
   // printf(" ~ ~ %d ~ ~ ",total_string);
   // printf(" ~ ~ %d ~ ~ ", $$->string_used);
}
;

while_stmt:   T_WHILE VAR RELOP NUM T_DO stmt {printf("rule:13 "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
	    $$->statement_type=WHILE_STATEMENT;
	    sprintf($$->initCode,"lw $t0, %s($t8)\nli $t1, %d\n", $2->addr,$4);
      //  printf("\n%d error point - \n",$3);
       int temp_relop = (int) $3;
       switch (temp_relop){case 1:
               sprintf($$->initJumpCode,"ble $t0, $t1,");
               break;
            case 2:
               sprintf($$->initJumpCode,"bge $t0, $t1,");
               break;
            case 3:
               sprintf($$->initJumpCode,"blt $t0, $t1,");
               break;
            case 4:
               sprintf($$->initJumpCode,"bgt $t0, $t1,");
               break;
            case 5:
               sprintf($$->initJumpCode,"bne $t0, $t1,");
               break;
            case 6:
               sprintf($$->initJumpCode,"beq $t0, $t1,");
               break;}
	    $$->down=$6;
	    }
|  T_WHILE VAR RELOP VAR T_DO stmt {printf("rule:13 "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
	    $$->statement_type=WHILE_STATEMENT;
	    sprintf($$->initCode,"lw $t0, %s($t8)\nlw $t1, %s($t8)\n", $2->addr,$4->addr);
       int temp_relop = (int) $3;
       switch (temp_relop){case 1:
               sprintf($$->initJumpCode,"ble $t0, $t1,");
               break;
            case 2:
               sprintf($$->initJumpCode,"bge $t0, $t1,");
               break;
            case 3:
               sprintf($$->initJumpCode,"blt $t0, $t1,");
               break;
            case 4:
               sprintf($$->initJumpCode,"bgt $t0, $t1,");
               break;
            case 5:
               sprintf($$->initJumpCode,"bne $t0, $t1,");
               break;
            case 6:
               sprintf($$->initJumpCode,"beq $t0, $t1,");
               break;}
	    $$->down=$6;
	    }       
|   T_WHILE '(' VAR RELOP NUM ')' T_DO stmt {printf("rule:13 "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
	    $$->statement_type=WHILE_STATEMENT;
	    sprintf($$->initCode,"lw $t0, %s($t8)\nli $t1, %d\n", $3->addr,$5);
	    
       int temp_relop = $4;
       switch (temp_relop)
            {case 1:
               sprintf($$->initJumpCode,"ble $t0, $t1,");
               break;
            case 2:
               sprintf($$->initJumpCode,"bge $t0, $t1,");
               break;
            case 3:
               sprintf($$->initJumpCode,"blt $t0, $t1,");
               break;
            case 4:
               sprintf($$->initJumpCode,"bgt $t0, $t1,");
               break;
            case 5:
               sprintf($$->initJumpCode,"bne $t0, $t1,");
               break;
            case 6:
               sprintf($$->initJumpCode,"beq $t0, $t1,");
               break;
            }
         $$->down=$8;
      }
|   T_WHILE '(' VAR RELOP VAR ')' T_DO stmt {printf("rule:13 "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
	    $$->statement_type=WHILE_STATEMENT;
	    sprintf($$->initCode,"lw $t0, %s($t8)\nlw $t1, %s($t8)\n", $3->addr,$5->addr);
	    
       int temp_relop = $4;
       switch (temp_relop)
            {case 1:
               sprintf($$->initJumpCode,"ble $t0, $t1,");
               break;
            case 2:
               sprintf($$->initJumpCode,"bge $t0, $t1,");
               break;
            case 3:
               sprintf($$->initJumpCode,"blt $t0, $t1,");
               break;
            case 4:
               sprintf($$->initJumpCode,"bgt $t0, $t1,");
               break;
            case 5:
               sprintf($$->initJumpCode,"bne $t0, $t1,");
               break;
            case 6:
               sprintf($$->initJumpCode,"beq $t0, $t1,");
               break;
            }
         $$->down=$8;
      };

for_stmt: T_FOR VAR T_ASSIGN exp TO exp T_DO stmt {printf("rule:13 "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
      
	    $$->statement_type=FOR_STATEMENT;
       sprintf($$->forinit,"%s\nsw $t0,%s($t8)\n",$4,$2->addr);
       if($5==1){
         sprintf($$->forincre,"\nlw $t0, %s($t8)\nli $t1, 1\nadd $t0, $t0, $t1\nsw $t0,%s($t8)\n",$2->addr,$2->addr);
         sprintf($$->initJumpCode,"bgt $t0, $t1,");
       }
       else{
         sprintf($$->forincre,"\nlw $t0, %s($t8)\nli $t1, 1\nsub $t0, $t0, $t1\nsw $t0,%s($t8)\n",$2->addr,$2->addr);
         sprintf($$->initJumpCode,"blt $t0, $t1,");
       }
	    sprintf($$->initCode,"%s\nmove $t1, $t0\nlw $t0, %s($t8)\n",$6 ,$2->addr);
      //  printf("\n%d error point - \n",$3);
         
	    $$->down=$8;
	    }
;

if_stmt: T_IF VAR RELOP exp T_THEN stmt T_ELSE stmt {
   printf("rule:if-a "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
   $$->statement_type=IF_ELSE_STATEMENT;
   sprintf($$->initCode,"%s\nmove $t1, $t0\nlw $t0, %s($t8)\n",$4 ,$2->addr);
          int temp_relop = $3;
       switch (temp_relop)
            {case 1:
               sprintf($$->initJumpCode,"ble $t0, $t1,");
               break;
            case 2:
               sprintf($$->initJumpCode,"bge $t0, $t1,");
               break;
            case 3:
               sprintf($$->initJumpCode,"blt $t0, $t1,");
               break;
            case 4:
               sprintf($$->initJumpCode,"bgt $t0, $t1,");
               break;
            case 5:
               sprintf($$->initJumpCode,"bne $t0, $t1,");
               break;
            case 6:
               sprintf($$->initJumpCode,"beq $t0, $t1,");
               break;
            }
   $$->down=$6; $$->down2=$8;
}
|      T_IF '(' VAR RELOP exp ')' T_THEN stmt T_ELSE stmt {
      printf("rule:if-b "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
   $$->statement_type=IF_ELSE_STATEMENT;
   sprintf($$->initCode,"%s\nmove $t1, $t0\nlw $t0, %s($t8)\n",$5 ,$3->addr);
          int temp_relop = $4;
       switch (temp_relop)
            {case 1:
               sprintf($$->initJumpCode,"ble $t0, $t1,");
               break;
            case 2:
               sprintf($$->initJumpCode,"bge $t0, $t1,");
               break;
            case 3:
               sprintf($$->initJumpCode,"blt $t0, $t1,");
               break;
            case 4:
               sprintf($$->initJumpCode,"bgt $t0, $t1,");
               break;
            case 5:
               sprintf($$->initJumpCode,"bne $t0, $t1,");
               break;
            case 6:
               sprintf($$->initJumpCode,"beq $t0, $t1,");
               break;
            }
   $$->down=$8; $$->down2=$10;
}
|      T_IF VAR RELOP exp T_THEN stmt {
   printf("rule:if-c "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
   $$->statement_type=IF_STATEMENT;
   sprintf($$->initCode,"%s\nmove $t1, $t0\nlw $t0, %s($t8)\n",$4 ,$2->addr);   
   $$->down=$6;
   int temp_relop = $3;
       switch (temp_relop)
            {case 1:
               sprintf($$->initJumpCode,"ble $t0, $t1,");
               break;
            case 2:
               sprintf($$->initJumpCode,"bge $t0, $t1,");
               break;
            case 3:
               sprintf($$->initJumpCode,"blt $t0, $t1,");
               break;
            case 4:
               sprintf($$->initJumpCode,"bgt $t0, $t1,");
               break;
            case 5:
               sprintf($$->initJumpCode,"bne $t0, $t1,");
               break;
            case 6:
               sprintf($$->initJumpCode,"beq $t0, $t1,");
               break;
            }
}
|      T_IF '(' VAR RELOP exp ')' T_THEN stmt {
   printf("rule:if-d "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
   $$->statement_type=IF_STATEMENT;
   sprintf($$->initCode,"%s\nmove $t1, $t0\nlw $t0, %s($t8)\n",$5 ,$3->addr);   
   $$->down=$8;
   int temp_relop = $4;
       switch (temp_relop)
            {case 1:
               sprintf($$->initJumpCode,"ble $t0, $t1,");
               break;
            case 2:
               sprintf($$->initJumpCode,"bge $t0, $t1,");
               break;
            case 3:
               sprintf($$->initJumpCode,"blt $t0, $t1,");
               break;
            case 4:
               sprintf($$->initJumpCode,"bgt $t0, $t1,");
               break;
            case 5:
               sprintf($$->initJumpCode,"bne $t0, $t1,");
               break;
            case 6:
               sprintf($$->initJumpCode,"beq $t0, $t1,");
               break;
            }
}
;


assign_stmt: VAR T_ASSIGN exp {printf("rule:14 "); $$=(struct StmtNode *) malloc(sizeof(struct StmtNode));
	    $$->statement_type=ASSIGNMENT_STATEMENT;
	    sprintf($$->bodyCode,"%s\nsw $t0,%s($t8)\n", $3, $1->addr);
	    $$->down=NULL;};

exp: '(' exp ')' {sprintf($$,"%s",$2);}
| x {printf("rule:15A "); sprintf($$,"%s",$1);count=(count+1)%2;}
| x '+' x  {printf("rule:15B "); sprintf($$,"%s\n%s\nadd $t0, $t0, $t1",$1,$3);}
| x '-' x  {printf("rule:15C "); sprintf($$,"%s\n%s\nsub $t0, $t0, $t1",$1,$3);}
| x '*' x  {printf("rule:15D "); sprintf($$,"%s\n%s\nmul $t0, $t0, $t1",$1,$3);}
| x T_DIV x  {printf("rule:15E ");  sprintf($$,"%s\n%s\ndiv $t0, $t0, $t1",$1,$3);};

x: NUM {printf("rule:16A "); sprintf($$,"li $t%d, %d",count,$1);count=(count+1)%2;}
| VAR {printf("rule:16B "); sprintf($$, "lw $t%d, %s($t8)",count,$1->addr);count=(count+1)%2;} ;

/* End of grammar */
%%

void StmtsTrav(stmtsptr ptr){
  printf("stmts\n");
  if(ptr==NULL) return;
  if(ptr->singl==1 && ptr->isLeftABlock==1) {StmtsTrav(ptr->leftblk); return;}
  if(ptr->singl==1 && ptr->isLeftABlock==0) {StmtTrav(ptr->leftstmt); return;} 
  else{
  StmtsTrav(ptr->leftblk);
  StmtsTrav(ptr->right);
  }
}
void StmtTrav(stmtptr ptr){
   int ws,nj;
   int ep, ei;
   printf("stmt\n");
   if(ptr==NULL) return;
   if(ptr->statement_type==ASSIGNMENT_STATEMENT){fprintf(fp,"%s\n",ptr->bodyCode);}
   if(ptr->statement_type==WHILE_STATEMENT){ws=whileStart; whileStart++;nj=nextJump;nextJump++;
     fprintf(fp,"\nLabStartWhile%d:%s\n%s NextPart%d\n",ws,ptr->initCode,ptr->initJumpCode,nj);StmtsTrav(ptr->down);
     fprintf(fp,"j LabStartWhile%d\nNextPart%d:\n",ws,nj);}
   if(ptr->statement_type==2){ws=whileStart; whileStart++;nj=nextJump;nextJump++;
     fprintf(fp,"%s",ptr->forinit);
    //  fprintf(fp,"writen init \n");
     fprintf(fp,"\nLabStartWhile%d:%s\n%s NextPart%d\n",ws,ptr->initCode,ptr->initJumpCode,nj);StmtsTrav(ptr->down);
    //  fprintf(fp,"writing forincr \n");
     fprintf(fp,"%s",ptr->forincre);
    //  fprintf(fp,"writt incr \n");
     fprintf(fp,"j LabStartWhile%d\nNextPart%d:\n",ws,nj);}
   if(ptr->statement_type==3) {
      ep = elsepart; elsepart++; ei=endif; endif++;
      fprintf(fp,"\n%s\n%s EndIf%d\n",ptr->initCode,ptr->initJumpCode,ep);StmtsTrav(ptr->down);
      fprintf(fp,"\nEndIf%d:",ei);
   }
   if(ptr->statement_type==4) fprintf(fp,"%s\n",ptr->bodyCode);
   if(ptr->statement_type==5) {
      ep = elsepart; elsepart++; ei=endif; endif++;
      fprintf(fp,"\n%s\n%s ElsePart%d\n",ptr->initCode,ptr->initJumpCode,ep);StmtsTrav(ptr->down);
      fprintf(fp,"\nj EndIf%d",ei);
      fprintf(fp,"\nElsePart%d:",ep);StmtsTrav(ptr->down2);

      fprintf(fp,"\nEndIf%d:",ei);
   }	  
   if(ptr->statement_type==READ_STATEMENT) fprintf(fp,"%s\n",ptr->bodyCode);

   if(ptr->statement_type==WRITE_STRING_STATE) {
   fprintf(fp,"\nli $v0,4 \nla $a0, string%d\nsyscall\n",ptr->string_used);
   fprintf(fp,"%s\n",ptr->bodyCode);
   }

}
   


int main ()
{
   fp=fopen("asmb.asm","w");
   fprintf(fp,".data\n");
  
   yyparse ();

   for(int i=0; i<total_string; i++) fprintf(fp,"\nstring%d:  .asciiz  \"%s\"",i,chrp+i*150);
   printf("%d tot_string %d\n",total_string,total_string);
   fprintf(fp,"\n\n.text\nli $t8,%d\n",268500992+total_string*150*4);

   StmtsTrav(final);
   // fprintf(fp,"\nli $v0,1\nmove $a0,$t0\nsyscall\n");
   fclose(fp);
}

void yyerror (char *s)  /* Called by yyparse on error */
{
  printf ("%s\n", s);
}


