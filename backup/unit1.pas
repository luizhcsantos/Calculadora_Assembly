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

  TPilha = record
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
    procedure FormCreate(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure ButtonEqualsClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);

  private
    { Private declarations }
    function AvaliarNP(expressao: string): Double;
    procedure AdicionaTextoMemo(const Texto: string);
    procedure IniciarPilha(var pilha: TPilha);
    procedure Push(var pilha: TPilha; valor: Double);
    function Pop(var pilha: TPilha): Double;
    function PilhaVazia(const stack: TPilha): Boolean;
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
  pilha: TPilha;
  postfix: string;
  i: integer;
  ch: char;
begin
  IniciarPilha(pilha);
  postfix := '';
  for i := 1 to Length(expression) do
  begin
    ch := expression[i];
    case ch of
      'a'..'z', 'A'..'Z', '0'..'9':
        postfix := postfix + ch + ' ';
      '(':
        Push(pilha, Ord(ch));
      ')':
        begin
          while (not PilhaVazia(pilha)) and (Char(pilha.dado[pilha.topo]) <> '(') do
          begin
            postfix := postfix + Char(Pop(pilha));
          end;
          if (not PilhaVazia(pilha)) then
            Pop(pilha); // Remover '(' da pilha
        end;
      '+', '-', '*', '/', '^':
        begin
          while (not PilhaVazia(pilha)) and (Precedence(Char(pilha.dado[pilha.topo])) >= Precedence(ch)) do
          begin
            postfix := postfix + Char(Pop(pilha));
          end;
          Push(pilha, Ord(ch));
        end;
    end;
  end;
  while (not PilhaVazia(pilha)) do
  begin
    postfix := postfix + Char(Pop(pilha));
  end;

  Result := postfix;
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
    btn := TButton(FindComponent('Button' + IntToSTr(i)));
    if Assigned(btn) then
       btn.OnClick := @ButtonClick;
  end;
  Button17.OnClick := @ButtonEqualsClick;
  Button31.OnClick := @ButtonClearClick;
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

// Operações da Pilha
//*******************
// Inicializar a pilha
procedure TForm1.IniciarPilha(var pilha: TPilha);
begin
  SetLength(pilha.dado, 0);
  pilha.topo := -1;
end;

// Colocar valores no topo da pilha
procedure TForm1.Push(var pilha: TPilha; valor: Double);
begin
  Inc(pilha.topo);
  SetLength(pilha.dado, pilha.topo + 1);
  pilha.dado[pilha.topo] := valor;
end;

// Retirar valores no topo da pilha
function TForm1.Pop(var pilha: TPilha): Double;
begin
  if pilha.topo < 0 then
    raise Exception.Create('Stack underflow');
  Result := pilha.dado[pilha.topo];
  Dec(pilha.topo);
end;

function TForm1.PilhaVazia(const stack: TPilha): Boolean;
begin
  Result := stack.topo < 0;
end;

function ehOperador(s: string): Boolean;
begin
  Result := (s = '+') or (s = '-') or (s = '*') or (s = '/');
end;

// Esta função recebe uma expressão na Notação Polonesa (NP)
// divide a expressão em tokens
// e processa cada token.
function TForm1.AvaliarNP(expressao: string): Double;
var
  pilha: TPilha;
  tokens: TStringArray;
  token: string;
  op1, op2: Double;
begin
  IniciarPilha(pilha);
  tokens := SplitString(expressao, ' ');

  for token in tokens do
  begin
    if TryStrToFloat(token, op1) then
    begin
      Push(pilha, op1);
    end
    else if ehOperador(token) then
    begin
      op2 := Pop(pilha);
      op1 := Pop(pilha);

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
      end;

      Push(pilha, op1);
    end
    else
    begin
      raise Exception.Create('Token inválido: ' + token);
    end;
  end;

  Result := Pop(pilha);
end;

function ehLetraOuDigito(c: Char): Boolean;
begin
  Result := CharInSet(c, ['A'..'Z', 'a'..'z', '0'..'9']);
end;

end.

