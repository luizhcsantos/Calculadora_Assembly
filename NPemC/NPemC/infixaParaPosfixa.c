#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Pilha.h"
#include "infixaParaPosfixa.h"

// Fun��o para verificar se um caractere � um operador
int isOperator(char c) {
    return (c == '+' || c == '-' || c == '*' || c == '/');
}

// Fun��o para verificar se um caractere � um d�gito
int isDigit(char c) {
    return (c >= '0' && c <= '9');
}

// Fun��o para tokenizar a express�o
Token* tokenizeExpression(char *expr, int *numTokens) {
    Token *tokens = malloc(strlen(expr) * sizeof(Token)); // Alocando mem�ria para o array de tokens
    int tokenCount = 0;

    // Percorrendo a string de express�o
    for (int i = 0; expr[i] != '\0'; i++) {
        // Ignorando espa�os em branco
        if (isspace(expr[i])) {
            continue;
        }
        // Se for um operador, adicion�-lo como um token
        else if (isOperator(expr[i])) {
            tokens[tokenCount].value[0] = expr[i];
            tokens[tokenCount].value[1] = '\0';
            tokens[tokenCount].type = 0; // Tipo 0 indica operador
            tokenCount++;
        }
        // Se for um d�gito, encontrar o n�mero completo e adicion�-lo como um token
        else if (isDigit(expr[i])) {
            int j = i;
            while (isDigit(expr[j])) {
                j++;
            }
            int length = j - i;
            strncpy(tokens[tokenCount].value, &expr[i], length);
            tokens[tokenCount].value[length] = '\0';
            tokens[tokenCount].type = 1; // Tipo 1 indica n�mero
            tokenCount++;
            i = j - 1; // Atualizar o �ndice para o pr�ximo caractere ap�s o n�mero
        }
        // Se for um par�ntese, adicion�-lo como um token
        else if (expr[i] == '(' || expr[i] == ')') {
            tokens[tokenCount].value[0] = expr[i];
            tokens[tokenCount].value[1] = '\0';
            tokens[tokenCount].type = 2; // Tipo 2 indica par�nteses
            tokenCount++;
        }
        // Se for um caractere inv�lido, imprimir uma mensagem de erro e sair
        else {
            printf("Erro: Caractere inv�lido na express�o.\n");
            exit(1);
        }
    }

    *numTokens = tokenCount; // Atualizando o n�mero de tokens
    return tokens;
}

// Fun��o para obter a preced�ncia de um operador
int precedence(char op) {
    switch (op) {
        case '+':
        case '-':
            return 1;
        case '*':
        case '/':
            return 2;
        case '^':
            return 3;
        default:
            return -1;
    }
}

// Fun��o para converter uma express�o infix para postfix
Token* InfixToPostfix(Token* expression, int length, int* resultLength) {
    Pilha *pilha = criaPilha(length);
    Token *postfix = (Token*)malloc(length * sizeof(Token));
    int k = 0;

    for (int i = 0; i < length; i++) {
        Token currentToken = expression[i];

        if (currentToken.type == 1) { // Operand
            postfix[k++] = currentToken;
        } else if (strcmp(currentToken.value, "(") == 0) {
            push(pilha, currentToken.value);
        } else if (strcmp(currentToken.value, ")") == 0) {
            while (!pilhaVazia(pilha) && strcmp(peek(pilha), "(") != 0) {
                strcpy(postfix[k++].value, pop(pilha));
            }
            if (!pilhaVazia(pilha) && strcmp(peek(pilha), "(") == 0) {
                pop(pilha);
            }
        } else if (currentToken.type == 0) { // Operator
            while (!pilhaVazia(pilha) && precedence(peek(pilha) >= precedence(currentToken.value[0]))) {
                strcpy(postfix[k++].value, pop(pilha));
            }
            push(pilha, currentToken.value);
        }
    }

    while (!isEmpty(pilha)) {
        strcpy(postfix[k++].value, pop(pilha));
    }

    *resultLength = k;
    free(pilha->topo);
    free(pilha);

    return postfix;
}


Token* infixaPosfixa(Token* expression, int numTokens) {
    Pilha *pilha = criaPilha();
    char *postfix = (char*)malloc((numTokens * 2 + 1) * sizeof(char));
    int i, k = 0;

    for (i = 0; expression[i].token; i++) {
        char *ch = expression[i].token;
        printf("%s.", expression[i].token);
        if ((expression[i].token >= 'a' && expression[i].token <= 'z') || (expression[i].token >= 'A' && expression[i].token <= 'Z') || (expression[i].token >= '0' && &ch <= '9')) {
            postfix[k++] = expression[i].token;
            postfix[k++] = ' ';
        } else if (expression[i].token == '(') {
            push(pilha, expression[i].token);
        } else if (expression[i].token == ')') {
            while (!pilhaVazia(pilha) && pilha->topo->info != '(') {
                postfix[k++] = pop(pilha);
                postfix[k++] = ' ';
            }
            if (!pilhaVazia(pilha) && pilha->topo->info == '(') {
                pop(pilha);
            }
        } else {
            while (!pilhaVazia(pilha) && precedence(pilha->topo->info) >= precedence(expression[i].token)) {
                postfix[k++] = pop(pilha);
                postfix[k++] = ' ';
            }
            push(pilha, expression[i].token);
        }
    }

    while (!pilhaVazia(pilha)) {
        postfix[k++] = pop(pilha);
        postfix[k++] = ' ';
    }

    postfix[k] = '\0';
    free(pilha);

    return postfix;
}
