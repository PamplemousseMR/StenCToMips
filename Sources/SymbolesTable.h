#ifndef __SYMBOLESTABLE_H
#define __SYMBOLESTABLE_H

#define BUFFER_SIZE 50

typedef enum bool{false,true} bool;

typedef struct s_node{
	char id[BUFFER_SIZE];
	char mipsId[BUFFER_SIZE];
	bool init;
	unsigned long long creationLabelCounter;
	struct s_node* next;
}*Node;

typedef Node* List;

List mallocList();
void freeList(List);

Node addNode(List, char*);
Node getNodeById(List, char*);
void removeNode(List, char*);
void removeAllNodeGreaterThan(List, int);


#endif