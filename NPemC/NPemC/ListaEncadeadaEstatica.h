
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#define MAX 10

struct reg {
	int elem;
	int prox;
};

struct lista {
	int disp;
	int prim;
	struct reg A[MAX];
};


void InicializaLista(struct lista *L);
void Imprime(struct lista *L);
void Insere(struct lista *L, int elem);
//bool Retira(struct lista *L, int pos);
bool listaVazia(struct lista *L);
