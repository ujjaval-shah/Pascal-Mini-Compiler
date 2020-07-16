%{
#include "calc.tab.h"
#include "calc.h"
#include<stdlib.h>

int Adr=0;
symrec *sym_table = (symrec *)0;
%}
number [0-9]+
id [a-z]+
text_data [A-Z_]+

%%
[ ] {}
"if" {return T_IF;}
"then" {return T_THEN;}
"else" {return T_ELSE;}
"input" {return T_INPUT;}
"read" {return T_READ;}
"write" {yylval.val=1; return T_WRITE;}
"writeln" {yylval.val=2; return T_WRITE;}
"to" {yylval.val=1; return TO;}
"downto" {yylval.val=2; return TO;}
"div" {return T_DIV;}
">" {yylval.val=1; return RELOP;}
"<" {yylval.val=2; return RELOP;}
">=" {yylval.val=3; return RELOP;}
"<=" {yylval.val=4; return RELOP;}
"=" {yylval.val=5; return RELOP;}
"<>" {yylval.val=6; return RELOP;}
"for" {return T_FOR;}
"while" {return T_WHILE;}
"do" {return T_DO;}
"program" {return T_PROGRAM;}
"var" {return T_VAR;}
";" {return T_EOL;}
"." {return T_DOT;}
":=" {return T_ASSIGN;}
"integer" {return T_INTEGER;}
"begin" {return T_BEGIN;}
"end" {return T_END;}
":" {return T_COLON;}
{text_data} { sprintf(yylval.c,"%s",yytext); return STRING;}
{number} {sscanf(yytext,"%d",&yylval.val); return NUM;}
{id} {symrec *s;s=getsym(yytext); if(s==0) s=putsym(yytext,VAR);yylval.tptr=s;return VAR;}
\n { printf("%s", "UNRECO n \n"); }
\t { printf("%s", "UNRECO tab \n"); }
.  { printf(":: %d ascii \n",yytext[0]); return yytext[0]; }
%%

/* The symbol table: a chain of `struct symrec'.  */


symrec * putsym (char *sym_name,int sym_type){
  symrec *ptr;
  ptr = (symrec *) malloc (sizeof (symrec));
  ptr->name = (char *) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name,sym_name);
  sprintf(ptr->addr,"%d",Adr); /* set value to 0 even if fctn.  */
  Adr=Adr+4;
  ptr->next = (struct symrec *)sym_table;
  sym_table = ptr;
  return ptr;
}

symrec *getsym (char *sym_name){
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next)
    if (strcmp (ptr->name,sym_name) == 0)
      return ptr;
  return 0;
}
