#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SymbolesTable.h"

extern unsigned long long labelCounter;
extern unsigned long long variableCounter;

List mallocList(){
	List l = (List)malloc(sizeof(struct s_node*));
	*l = NULL;
	return l;
}

void freeNodeBis(Node n){
	if(n != NULL) 
		freeNodeBis(n->next);
	free(n);
}

void freeList(List l){
	freeNodeBis(*l);
	free(l);
	l = NULL;
}

Node addNodeBis(Node n, char* c){
	if(n == NULL){
		Node result = (Node)malloc(sizeof(struct s_node));
		strncpy(result->id,c,BUFFER_SIZE);
		snprintf(result->mipsId,BUFFER_SIZE,"var_%llu",variableCounter++);
		result->init = false;
		result->creationLabelCounter = labelCounter;
		result->next = NULL;
		return result;
	}else {
		if(strcmp(n->id,c))
			n->next = addNodeBis(n->next, c);
		return n;
	}
}

Node addNode(List l, char* c){
	*l = addNodeBis(*l,c);
	return getNodeById(l,c);
}

Node getNodeByIdBis(Node n, char* c){
	if(n == NULL) return NULL;
	if(!strcmp(n->id,c)) return n;
	return getNodeByIdBis(n->next,c);
}

Node getNodeById(List l, char* c){
	return getNodeByIdBis(*l, c);
}

Node removeNodeBis(Node n, char* c){
	if(n == NULL) return NULL;
	if(!strcmp(n->id,c)){
		Node tmp = n->next;
		free(n);
		return tmp;
	}else{
		n->next = removeNodeBis(n->next,c);
		return n;
	}
}

void removeNode(List l, char* c){
	*l = removeNodeBis(*l, c);
}

Node removeAllNodeGreaterThanBis(Node n,unsigned int i){
	if(n == NULL) return NULL;
	n->next = removeAllNodeGreaterThanBis(n->next,i);
	if(n->creationLabelCounter >= i){
		Node tmp = n->next;
		free(n);
		return tmp;
	}else{
		return n;
	}
}

void removeAllNodeGreaterThan(List l, int i){
	*l = removeAllNodeGreaterThanBis(*l, i); 
}

/*static void printNodesBis(Node n){
	if(n == NULL) 
		return;
	printf("\t Node %s %s %d %llu",n->id,n->mipsId,n->init,n->creationLabelCounter);
	printNodesBis(n->next);
}

static void printList(List l){	
	printNodesBis(*l);
}


int main(){
	List list = mallocList();
	printList(list);
	
	printf("\n");
	addNode(list,"deux",true);
	addNode(list,"trois",true);
	addNode(list,"quatre",true);
	printList(list);
	printf("\n");
	removeNode(list,"trois");
	printList(list);
	printf("\n");
	removeNode(list,"quatre");
	printList(list);
	printf("\n");
	removeNode(list,"deux");
	removeNode(list,"un");
	printList(list);
	freeList(list);
}*/