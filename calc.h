/* Data type for links in the chain of symbols.      */
struct symrec
{
  char *name;          /* name of symbol                     */
  char addr[100];      /* value of a VAR          */
  struct symrec *next; /* link field              */
};

enum STMT_TYPE {
  ASSIGNMENT_STATEMENT=0,
  WHILE_STATEMENT=1,
  FOR_STATEMENT=2,
  IF_STATEMENT=3,
  WRITE_STATEMENT=4,
  IF_ELSE_STATEMENT=5,
  READ_STATEMENT=6,
  WRITE_STRING_STATE=7
}; 

typedef struct symrec symrec;

/* The symbol table: a chain of `struct symrec'.     */
extern symrec *sym_table;

symrec *putsym();
symrec *getsym();

typedef struct StmtsNode *stmtsptr;
typedef struct StmtNode *stmtptr;

struct StmtsNode
{
  int singl;
  int isLeftABlock;
  struct StmtNode *leftstmt;
  struct StmtsNode *leftblk;
  struct StmtsNode *right;
};

struct StmtNode
{
  int statement_type;
  char initCode[100];
  char initJumpCode[20];
  char bodyCode[1000];
  struct StmtsNode *down; // IF block
  struct StmtsNode *down2; // ELSE block
  char forinit[200];
  char forincre[100];
  int string_used;
};
/*void StmtsTrav(stmtsptr ptr);
  void StmtTrav(stmtptr *ptr);*/
