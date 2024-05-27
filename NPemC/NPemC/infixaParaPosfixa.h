#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>


typedef struct {
    char value[20];
    int type; // Tipo do token: 0 para operador, 1 para número, 2 para parênteses
} Token;

int isOperator(char c);
int isDigit(char c);
Token* tokenizeExpression(char *expr, int *numTokens);
int precedence(char op);
char* infixaPostfixa(char* expression);
Token* infixaPosfixa(Token* expression, int numTokens);
