unit Unit1;

{$mode objfpc}{$H+}

// Trabalho Bimestral de Microprocessadores
// Calculadora Científica utilizando a Notação Polonesa (também chamada de Notação Pós-fixa)
// Os cálculos são realizados em Assembly

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
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Memo1: TMemo;
    procedure Button11Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure ButtonEqualsClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);

  private
    { Private declarations }
    function AvaliarNP(expressao: string): Double;
    procedure AdicionaTextoMemo(const Texto: string);
    procedure IniciarPilhaChar(var pilha: TPilhaChar);
    procedure PushChar(var pilha: TPilhaChar; valor: Char);
    function PopChar(var pilha: TPilhaChar): Char;
    function PilhaCharVazia(const pilha: TPilhaChar): Boolean;

    procedure IniciarPilhaDouble(var pilha: TPilhaDouble);
    procedure PushDouble(var pilha: TPilhaDouble; valor: Double);
    function PopDouble(var pilha: TPilhaDouble): Double;
    function PilhaDoubleVazia(const pilha: TPilhaDouble): Boolean;

    function InfixToPostfix(expression: string): string;

  public
    { Public declarations }

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

function Precedence(op: char): integer;
begin
  case op of
    '~': Precedence := 6;
    '^': Precedence := 5;
    '*', '/': Precedence := 4;
    '+', '-': Precedence := 3;
    '(': Precedence := 1;
  else
    Precedence := 0;
  end;
end;

function TForm1.InfixToPostfix(expression: string): string;
var
  P1: TPilhaChar;      // pilha para armazenas os operadores
  L1: TStringList;     // lista para armazenar os valores da operação
  i: integer;
  ch: char;
begin
  IniciarPilhaChar(P1);
  L1 := TStringList.Create;
  try
    for i := 1 to Length(expression) do
    begin
      ch := expression[i];
      case ch of
        'a'..'z', 'A'..'Z', '0'..'9':
          L1.Add(ch);
        '(':
          PushChar(P1, ch);
        ')':
          begin
            while (not PilhaCharVazia(P1)) and (P1.dado[P1.topo] <> '(') do
            begin
              L1.Add(PopChar(P1));
            end;
            if (not PilhaCharVazia(P1)) then
              PopChar(P1); // Remover '(' da pilha
          end;
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
    while (not PilhaCharVazia(P1)) do
    begin
      L1.Add(PopChar(P1));
    end;

    Result := L1.Text.Replace(sLineBreak, ' ');
  finally
    L1.Free;
  end;
end;

procedure TForm1.AdicionaTextoMemo(const Texto: string);
begin
  Memo1.Lines.Add(Texto);
end;

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

procedure TForm1.ButtonClick(Sender: TObject);
begin
  // Concatena o texto do botão ao Edit1
  Edit1.Text := Edit1.Text + (Sender as TButton).Caption + ' ';
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

function ehOperador(s: string): Boolean;
begin
  Result := (s = '+') or (s = '-') or (s = '*') or (s = '/') or (s = '~');
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
begin
  IniciarPilhaDouble(pilha);
  tokens := SplitString(expressao, ' ');

  foundNil := False;

  for token in tokens do
  begin
    if token = '' then
    begin
      foundNil := True;
      Break;
    end;
    if TryStrToFloat(token, op1) then // se o token é um número é colocado na pilha
    begin
      PushDouble(pilha, op1);
    end
    else if ehOperador(token) then
begin
  if token <> '~' then // Operações que requerem dois operandos
  begin
    // se o token é um operador diferente de '~', dois operandos são retirados da pilha
    // e a operação é realizada em assembly
    op2 := PopDouble(pilha);
    op1 := PopDouble(pilha);
  end
  else // Operação que requer apenas um operando
  begin
    // se o token é '~', apenas um operando é retirado da pilha
    // e a operação de negativo é realizada em assembly
    op1 := PopDouble(pilha);
  end;

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
  else if token = '~' then
  asm
    fld op1
    fchs
    fstp op1
  end;

  PushDouble(pilha, op1);
end;

    end
    else
    begin
      raise Exception.Create('Token Invalido: ' + token);
    end;
  end;

  if foundNil then
  begin
    Result := PopDouble(pilha);
    //raise Exception.Create('Valor "ANSISTRING(nil)" encontrado. Encerrando o processamento.');
  end;

  //Result := PopDouble(pilha);
end;

function ehLetraOuDigito(c: Char): Boolean;
begin
  Result := CharInSet(c, ['A'..'Z', 'a'..'z', '0'..'9']);
end;

end.

