#ifndef __SYMBOLESTABLE_H
#define __SYMBOLESTABLE_H

#define BUFFER_SIZE 50

typedef enum bool{false,true} bool;

typedef struct s_node{
	char id[BUFFER_SIZE];
	bool init;
	struct s_node* next;
}*Node;

typedef Node* List;


List mallocList();

void printList(List l);

void freeList(List l);

void addNode(List l, char* c, bool b);

void removeNode(List l,char* c);

Node getNodeById(List l, char* c);

#endif