unit Unit1;

{$mode objfpc}{$H+}

// Trabalho Bimestral de Microprocessadores
// Calculadora Científica utilizando a Notação Polonesa (também chamada de Notação Pós-fixa)
// Todos os cálculos são realizados em Assembly

interface

{$ASMMODE intel}

uses
  Interfaces, Classes, SysUtils, StrUtils, Forms,
  Controls, Graphics, Dialogs, StdCtrls;

type

  TPilhaChar = record
    dado: array of Char;
    topo: Integer;
  end;

  TPilhaDouble = record
    dado: array of Double;
    topo: Integer;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton; // botão de '='
    Button18: TButton;
    Button19: TButton;
    Button2: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
    Button29: TButton;
    Button3: TButton;
    Button30: TButton;
    Button31: TButton; // Botão 'C' para limpar
    Button32: TButton;
    Button33: TButton; // botão '('
    Button34: TButton; // botão ')'
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure Button11Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure ButtonEqualsClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);

  private
    { Private declarations }
    function AvaliarNP(expressao: string): Double;
    procedure IniciarPilhaChar(var pilha: TPilhaChar);
    procedure PushChar(var pilha: TPilhaChar; valor: Char);
    function PopChar(var pilha: TPilhaChar): Char;
    function PilhaCharVazia(const pilha: TPilhaChar): Boolean;

    procedure IniciarPilhaDouble(var pilha: TPilhaDouble);
    procedure PushDouble(var pilha: TPilhaDouble; valor: Double);
    function PopDouble(var pilha: TPilhaDouble): Double;
    function PilhaDoubleVazia(const pilha: TPilhaDouble): Boolean;

    function InfixToPostfix(expressao: string): string;
    function ehLetraOuDigito(c: Char): Boolean;
    function Precedence(op: string): integer;
    function ehOperador(s: string): Boolean;
    function ehOperacaoEspecial(op: string): Boolean;


  public
    { Public declarations }

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
  btn: TButton;
begin
  for i := 1 to 34 do
  begin
    btn := TButton(FindComponent('Button' + IntToStr(i)));
    if Assigned(btn) then
       btn.OnClick := @ButtonClick;
  end;
  Button17.OnClick := @ButtonEqualsClick;
  Button31.OnClick := @ButtonClearClick;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin

end;

// Função para limpar a caixa de texto ao clicar no botão 'C'
procedure TForm1.Button32Click(Sender: TObject);
begin
  Edit1.Text := '';
end;

// Definição da precendência das operações
function TForm1.Precedence(op: string): integer;
begin
  case op of
    '~': Precedence := 6; // troca de sinal
    '^': Precedence := 5; // potência
    'sqrt': Precedence := 5; // raiz quadrada
    'log', 'lan': Precedence := 5; // log  e log na base e
    'cos', 'sin', 'tan': Precedence := 5; // cosseno, seno e tangente
    '*', '/': Precedence := 4;
    '+', '-': Precedence := 3;
    '<', '>': Precedence := 2; // não há implementação de < ou > na nossa calculadora
    '(': Precedence := 1;
    ')': Precedence := 0;
  else
    Precedence := -1;
  end;
end;

function TForm1.ehOperacaoEspecial(op: string): Boolean;
  var
    j: Integer;
    operacoesEspeciais: array of string;
  begin
    operacoesEspeciais := ['sqrt', 'log', 'sin', 'cos', 'tan'];
    Result := False;
    for j := Low(operacoesEspeciais) to High(operacoesEspeciais) do
    begin
      if op = operacoesEspeciais[j] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

function TForm1.InfixToPostfix(expressao: string): string;
var
  P1: TPilhaChar;      // pilha para armazenar os operadores
  L1: TStringList;     // lista para armazenar os valores da operação
  i: integer;
  ch: char;
  tempNum: string;     // variável temporária para acumular os digitos de um número (necessário para não separar números com 2 ou mais digitos)
  tempOp: string;      // variável temporária para acumualr os caracteres que compõem o nome de uma função (ex: 's', 'q', 'r' e 't' = sqrt)
  //operacoesEspeciais: array of string;

  // função para verificar se a operação é uma das operações especiais sqrt, log, sin, cos, tan, etc.


begin
  IniciarPilhaChar(P1);
  L1 := TStringList.Create;
  tempNum := '';
  tempOp := '';
  try
    i := 1;
    while i <= Length(expressao) do
    begin
      ch := expressao[i];
      // ch é um número
      if ch in ['0'..'9', '.'] then
      begin
        tempNum := tempNum + ch; // Acumula o número
      end
      else
      // ch é (parte de) uma operação
      begin
        if tempNum <> '' then
        begin
          L1.Add(tempNum); // Adiciona o numero acumulado à lista
          tempNum := '';
        end;

      if ch in ['a'..'z', 'A'..'Z'] then
      begin
        tempOp := tempOp + ch;   // Acumula a operação especial
        // Verifica se é uma operação especial completa
        if ehOperacaoEspecial(tempOp) then
        begin
          //PushChar(P1, tempOp[1]); // Empilha um '(' para a operação especial
          L1.Add(tempOp);    // Adiciona a operação especial à lista
          tempOp := '';
          end;
        end
      else
      begin
        if tempOp <> '' then
        begin
          L1.Add(tempOp);  // Adiciona a operação acumulada à lista
          tempOp := '';
          end;
        case ch of
          '(':
            PushChar(P1, ch);
          ')':
            begin
            // Remove todos os elementos da pilha e adiciona na lista, até encontrar um (
              while (not PilhaCharVazia(P1)) and (P1.dado[P1.topo] <> '(') do
              begin
                L1.Add(PopChar(P1));
              end;
              if (not PilhaCharVazia(P1)) then
                PopChar(P1); // Remover '(' da pilha
              if (not PilhaCharVazia(P1)) and (P1.dado[P1.topo] <> '(') then
              begin
                L1.Add(PopChar(P1)); // Adiciona a operação especial
                end;
            end;
          // Operações simples
          '+', '-', '*', '/', '^', '~':
            begin
              while (not PilhaCharVazia(P1)) and (Precedence(P1.dado[P1.topo]) >= Precedence(ch)) do
              begin
                L1.Add(PopChar(P1));
              end;
              PushChar(P1, ch);
            end;
          end;
      end;
    end;
    Inc(i);
    end;

    if tempNum <> '' then
    begin
      L1.Add(tempNum); // Adiciona o último número acumulado, se houver
    end;
    if tempOp <> '' then
    begin
      L1.Add(tempOp);  // Adiciona a última operação acumulada, se houver
      end;
    while (not PilhaCharVazia(P1)) do
    begin
      L1.Add(PopChar(P1));
    end;

    Result := L1.Text.Replace(sLineBreak, ' ');
  finally
    L1.Free;
  end;
end;



procedure TForm1.ButtonClick(Sender: TObject);
var
  textoAtual: string;
  numeroDigitado: string;
  tamanho: Integer;
  i: Integer;
  operacoesEspeciais: array of string;  
  isOperacaoEspecial: Boolean;
begin
  // Lista de operações especiais
  operacoesEspeciais := ['sqrt', 'log', 'sin', 'cos'];

  // Obtém o dígito do botão clicado
  numeroDigitado := (Sender as TButton).Caption;

  // Verifica se o texto atual do Edit1 é vazio
  if Edit1.Text = '' then
  begin
    // Se o texto estiver vazio, apenas adiciona o dígito ao Edit1
    Edit1.Text := numeroDigitado + ' ';
    Exit;
  end;

  // Se chegamos aqui, significa que já há algum texto no Edit1
  // Vamos verificar se o último caractere é um operador
  textoAtual := TrimRight(Edit1.Text);
  tamanho := Length(textoAtual);

  isOperacaoEspecial := False;
  for i := Low(operacoesEspeciais) to High(operacoesEspeciais) do
  begin
    if numeroDigitado = operacoesEspeciais[i] then
    begin
      numeroDigitado := operacoesEspeciais[i] + ' ';
      isOperacaoEspecial := True;
      Break;
    end;
  end;

  if not isOperacaoEspecial and ehOperador(numeroDigitado) then
  begin
    // Se for outro operador, adicione um espaço antes do operador
    numeroDigitado := ' ' + numeroDigitado;
  end;


  if textoAtual[tamanho] in ['+', '-', '*', '/', '~'] then
  begin
    // Se o último caractere for um operador, adicione um espaço antes de adicionar o próximo dígito
    Edit1.Text := textoAtual + ' ' + numeroDigitado;
  end
  else
  begin
    // Se o último caractere não for um operador, apenas adicione o dígito ao Edit1
    Edit1.Text := textoAtual + numeroDigitado;
  end;
end;

// Esta função recebe uma expressão na Notação Polonesa (NP)
// divide a expressão em tokens
// e processa cada token.
function TForm1.AvaliarNP(expressao: string): Double;
var
  pilha: TPilhaDouble;
  tokens: TStringArray;
  token: string;
  op1, op2: Double;
  foundNil: Boolean;
  base: Double;
  x: Double;
  i: integer;
begin
  IniciarPilhaDouble(pilha);
  tokens := SplitString(expressao, ' ');

  foundNil := False;

  i := 0;
  while i < Length(tokens) do
  begin
    token := tokens[i];
    if token = '' then
    begin
      foundNil := True;
      Break;
    end;
    if TryStrToFloat(token, op1) then // se o token é um número, é colocado na pilha
    begin
      PushDouble(pilha, op1);
    end
    else if ehOperador(token) then
    begin
      if (not PilhaDoubleVazia(pilha)) then
      begin
        base := 10;
      //if (token = '~') or (token = 'sqrt') or (token = 'log') or (token = 'cos') or (token = 'sin') then // Operações que requerem dois operandos
      //begin

        if token = '~' then
        begin
          op1 := PopDouble(pilha);
          asm
           fld op1
           fchs
           fstp op1
          end;
          op1 := PopDouble(pilha);
        end

       else // Operações que requerem dois operandos
       begin
            op2 := PopDouble(pilha);
            op1 := PopDouble(pilha);
            if token = '+' then
            asm
              fld op1
              fadd op2
              fstp op1
            end
            else if token = '-' then
            asm
              fld op1
              fsub op2
              fstp op1
            end
            else if token = '*' then
            asm
              fld op1
              fmul op2
              fstp op1
            end
            else if token = '/' then
            asm
              fld op1
              fdiv op2
              fstp op1
            end
            else if token = '^' then  // x^y
            asm
             fld op1
             fld1
             fld op2
             fyl2x
             fmul
             fld st
             frndint
             fsub st(1), st
             fxch
             f2xm1
             fld1
             fadd
             fscale
             fstp op1
            end;
            PushDouble(pilha, op1);
       end;
    end
    else
    //begin
    //  raise Exception.Create('Erro: Pilha vazia ao tentar aplicar operador binário.');
    //end;
    end
    else if ehOperacaoEspecial(token) then
    begin
      if i + 1 < Length(tokens) then
      begin
        Inc(i);
        if TryStrToFloat(tokens[i], op1) then
        begin
          PushDouble(pilha, op1);
          op1 := PopDouble(pilha);
          if token = 'sqrt' then
          asm
           fld op1
           fsqrt
           fstp op1
          end
          else if token = 'log' then
          asm
           finit          //inicializa a pilha
           fld1           //[ 1.0 ]
           fld base       //[ n ; 1.0 ] // para fazer 1 * log2n
           fyl2x          //[ log2n ] // st = st(1).log2(st)
           fld1           //[ 1.0 ; log2n ]
           fdiv st, st(1) //[ 1.0 / log2n ]
           fld op1        //[ x ; 1.0 / log2n ]
           fyl2x          //[1.0 / log2n * log2x ] // st = st(1).log2(st)
           fstp op1
          end
          else if token = 'cos' then
          asm
           fld op1
           fcos
           fstp op1
          end
          else if token = 'sin' then
          asm
           fld op1
           fsin
           fstp op1
          end
          else if token = 'tan' then
          asm
           fld op1
           fptan
           fstp op1
          end;
          PushDouble(pilha, op1);
        end
    else
    begin
     raise Exception.Create('Erro: Token inválido após operação especial: ' + tokens[i]);
    end;
    end
    else
    begin
      raise Exception.Create('Erro: Operação especial sem operando.');
    end;
  end
else
begin
  raise Exception.Create('Token Inválido: ' + token);
  end;
Inc(i);
  end;

  if foundNil then
  begin
    Result := PopDouble(pilha);
    //raise Exception.Create('Valor "ANSISTRING(nil)" encontrado. Encerrando o processamento.');
  end;

  //Result := PopDouble(pilha);
end;




procedure TForm1.ButtonEqualsClick(Sender: TObject);
var
  expressaoInfixa, expressaoNP: string;
  resultado: Double;
begin
  try
    // Obtém a expressão infixa do Edit1
    expressaoInfixa := Edit1.Text;

    // Converte a expressão infixa para NP
    expressaoNP := InfixToPostfix(expressaoInfixa);
    Edit2.Text := expressaoNP;

    // Calcula o resultado da expressão NP
    resultado := AvaliarNP(expressaoNP);

    // Exibe o resultado no Edit1
    Edit1.Text := FloatToStr(resultado);
  except
    on E: Exception do
      Edit1.Text := 'Error: ' + E.Message;
  end;
end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
  // Limpa o conteúdo do Edit1
  Edit1.Text := '';
  Edit2.Text := '';
end;

// Operações da Pilha de Char
procedure TForm1.IniciarPilhaChar(var pilha: TPilhaChar);
begin
  SetLength(pilha.dado, 0);
  pilha.topo := -1;
end;

procedure TForm1.PushChar(var pilha: TPilhaChar; valor: Char);
begin
  Inc(pilha.topo);
  SetLength(pilha.dado, pilha.topo + 1);
  pilha.dado[pilha.topo] := valor;
end;

function TForm1.PopChar(var pilha: TPilhaChar): Char;
begin
  if pilha.topo < 0 then
    raise Exception.Create('Stack underflow');
  Result := pilha.dado[pilha.topo];
  Dec(pilha.topo);
end;

function TForm1.PilhaCharVazia(const pilha: TPilhaChar): Boolean;
begin
  Result := pilha.topo < 0;
end;

// Operações da Pilha de Double
procedure TForm1.IniciarPilhaDouble(var pilha: TPilhaDouble);
begin
  SetLength(pilha.dado, 0);
  pilha.topo := -1;
end;

procedure TForm1.PushDouble(var pilha: TPilhaDouble; valor: Double);
begin
  Inc(pilha.topo);
  SetLength(pilha.dado, pilha.topo + 1);
  pilha.dado[pilha.topo] := valor;
end;

function TForm1.PopDouble(var pilha: TPilhaDouble): Double;
begin
  if pilha.topo < 0 then
    raise Exception.Create('Stack underflow');
  Result := pilha.dado[pilha.topo];
  Dec(pilha.topo);
end;

function TForm1.PilhaDoubleVazia(const pilha: TPilhaDouble): Boolean;
begin
  Result := pilha.topo < 0;
end;

function TForm1.ehOperador(s: string): Boolean;
begin
  Result := (s = '+') or (s = '-') or (s = '*') or (s = '/') or (s = '~') or (s = 'sqrt') or (s = 'log') or (s = 'cos');
end;

function TForm1.ehLetraOuDigito(c: Char): Boolean;
begin
  Result := CharInSet(c, ['A'..'Z', 'a'..'z', '0'..'9']);
end;

end.

