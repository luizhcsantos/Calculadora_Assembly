#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct no {
	char info[20];
	struct no *prox;
}no;

typedef struct pilha {
	no *topo;
}Pilha;

void inserePilha(Pilha *p, int *ptraux, int escolha);


Pilha* criaPilha();
bool pilhaVazia(Pilha *p);
void imprime(Pilha *p);
int tamanho(Pilha *p);
void push(Pilha *p, char info);
char pop(Pilha *p);
char peek(Pilha *pilha);

