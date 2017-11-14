#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SymbolesTable.h"

List mallocList(){
	List l = (List)malloc(sizeof(struct s_node*));
	*l = NULL;
	return l;
}

void printNodesBis(Node n){
	if(n == NULL) 
	{	
		printf("\n");
		return;
	}
	printf("\t Node %s %d",n->id,n->init);
	printNodesBis(n->next);
}

void printList(List l){	
	printNodesBis(*l);
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

Node addNodeBis(Node n, char* c, bool b){
	if(n == NULL){
		Node result = (Node)malloc(sizeof(struct s_node));
		strncpy(result->id,c,BUFFER_SIZE);
		result->init = false;
		result->next = NULL;
		return result;
	}else {
		if(strcmp(n->id,c))
			n->next = addNodeBis(n->next, c, b);
		return n;
	}
}

void addNode(List l, char* c, bool b){
	*l = addNodeBis(*l,c,b);
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

void removeNode(List l,char* c){
	*l = removeNodeBis(*l,c);
}

Node getNodeByIdBis(Node n, char* c){
	if(n == NULL) return NULL;
	if(!strcmp(n->id,c)) return n;
	return getNodeByIdBis(n->next,c);
}

Node getNodeById(List l, char* c){
	return getNodeByIdBis(*l, c);
}

/*
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