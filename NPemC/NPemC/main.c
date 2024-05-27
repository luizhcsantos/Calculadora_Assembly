#include <stdio.h>
#include <stdlib.h>
#include "ListaEncadeadaEstatica.h"
#include "Pilha.h"
#include "infixaParaPosfixa.h"

int main(){

    struct lista L1;
	InicializaLista(&L1);
//	Insere(&L1, 2);
//	Imprime(&L1);

    Pilha *p;
    p = criaPilha();
    //push(p, 12);
//    imprime(p);

    char expressao[] = "2+(3*4)";

    int numTokens;
    Token *tokens = tokenizeExpression(expressao, &numTokens);

//    char np_exp[numTokens];
//    strcpy(np_exp, expressao);
//
//    // Imprimindo os tokens
    printf("Tokens:\n");
    for (int i = 0; i < numTokens; i++) {
        printf("token type: %d\ttoken: %s \n", tokens[i].type, tokens[i].value);
        //np_exp[i] = tokens[i].token;
    }
    printf("\n");
//    printf("%s",np_exp);


    Token* aux = infixaPosfixa(tokens, numTokens);

//    for (int i = 0; i < numTokens; i++) {
//        printf("%s ", aux[i].token);
//    }
//    printf("\n");

    // Liberando a memória alocada para os tokens
//    for (int i = 0; i < numTokens; i++) {
//        free(tokens[i].token);
//    }
//
//
//    free(tokens);

    return 0;
    system("pause");


}
