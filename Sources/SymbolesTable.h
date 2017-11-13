#ifndef __SYMBOLESTABLE_H
#define __SYMBOLESTABLE_H

#define BUFFER_SIZE 50

typedef enum bool{false,true} bool;

typedef struct s_node{
	char id[BUFFER_SIZE];
	bool init;
	struct s_node* next;
}*Node;

#endif