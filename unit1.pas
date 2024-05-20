unit Unit1;

{$mode objfpc}{$H+}

interface

{$ASMMODE intel}

uses
  Classes, SysUtils, StrUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

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
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton; 
    procedure FormCreate(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure ButtonEqualsClick(Sender: TObject);    
    procedure ButtonClearClick(Sender: TObject);


  private
    { Private declarations }
    ExpressaoNP: string;
    function AvaliarNP(expressao: string): Double;
    function InfixaParaNP(infixa: string): string;

  public
    { Public declarations }

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

type TPilha = record
      dado: array of Double;
      topo: Integer;
      end;


procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
  btn: TButton;
begin
  Edit1.Text := ''; // Inicializa o Edit1 com uma string vazia
end;

procedure TForm1.ButtonClick(Sender: TObject);
begin
  // Concatena o texto do botão ao Edit1
  Edit1.Text := Edit1.Text + (Sender as TButton).Caption;
end;


procedure TForm1.ButtonEqualsClick(Sender: TObject);
var
  expressaoInfixa, expressaoNP: string;
  resultado: Double;
begin
    try
      // Obtém a expressão infix do Edit1
      expressaIfixa := Edit1.Text;

      // Converte a expressão infixa para NP
      expressaoNP := InfixaParaNP(expressaoInfixa);

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

function TForm1.InfixaParaNP(infix: string): string;
begin

end;


// Operações da Pilha
//*******************
// Inicializar a pilha
procedure IniciarPilha(var stack: TPilha);
begin
  SetLength(stack.dado, 0);
  stack.topo := -1;
end;

// Colocar valores no topo da pilha
procedure Push(var stack: TPilha; valor: Double);
begin
  Inc(stack.topo);
  SetLength(stack.dado, stack.topo + 1);
  stack.dado[stack.topo] := valor;
end;

// Retirar valores no topo da pilha
function Pop(var stack: TPilha) : Double;
begin
    if stack.topo < 0 then
    raise Exception.Create('Stack underflow');
    Result := stack.dado[stack.topo];
    Dec(stack.topo);
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
        if TryStrToFloat(token, op1) then // se o token é um número é colocado na pilha
        begin
          Push(pilha, op1);
        end
        else if ehOperador(token) then
        // se o token é um operador, dois operandos são retirados da pilha
        // e a operação é realizada em assembly
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
        raise Exception.Create('Token Invalido: ' + token);
      end;
     end;

      Result := Pop(pilha);
end;








end.

