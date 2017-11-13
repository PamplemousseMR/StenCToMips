#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SymbolesTable.h"


void printNodesBis(Node n){
	if(n == NULL) {printf("\n");return;}
	printf("\t Node %s %d",n->id,n->init);
	printNodesBis(n->next);
}

void printNodes(Node* n){
	printNodesBis(*n);
}

void freeNodeBis(Node* n){
	if(n != NULL) freeNode(n->next);
	free(n);
}

void freeNode(Node n){
	freeNodeBis(*n);
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

void addNode(Node* n, char* c, bool b){
	*n = addNodeBis(*n,c,b);
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

void removeNode(Node* n,char* c){
	*n = removeNodeBis(*n,c);
}

Node getNodeByIdBis(Node n, char* c){
	if(n == NULL) return NULL;
	if(!strcmp(n->id,c)) return n;
	return getNodeByIdBis(n->next,c);
}

Node getNodeById(Node* n, char* c){
	return getNodeByIdBis(*n, c);
}


int main(){
	Node* root = NULL;
	printf("\n");
	addNode(root,"deux",true);
	addNode(root,"trois",true);
	addNode(root,"quatre",true);
	printNodes(root);
	printf("\n");
	removeNode(root,"trois");
	printNodes(root);
	printf("\n");
	removeNode(root,"quatre");
	printNodes(root);
	printf("\n");
	removeNode(root,"deux");
	removeNode(root,"un");
	printNodes(root);
	freeNode(root);
}