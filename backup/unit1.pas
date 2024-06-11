unit Unit1;

{$mode objfpc}{$H+}

// Trabalho Bimestral de Microprocessadores
// Calculadora Científica utilizando a Notação Polonesa (também chamada de Notação Pós-fixa)
// Todos os cálculos são realizados em Assembly

interface

{$ASMMODE intel}

uses
  Interfaces, Classes, SysUtils, StrUtils, Forms,
  Controls, Graphics, Dialogs, StdCtrls, Math;

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
    btnTan: TButton;
    Button2: TButton;
    btnCos: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    btnSin: TButton;
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
    chkInversa: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    chkGraus: TRadioButton;
    chkRadianos: TRadioButton;
    procedure Button11Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure chkInversaChange(Sender: TObject);
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
    function ehOperacaoEsp(op: string): Boolean;

    procedure Troca(var A, B: Double);
    //procedure chkGrausClick(Sender: TObject);
    //procedure chkRadianosClick(Sender: TObject);
    function GrausParaRadianos(graus: Double): Double;
    function RadianosParaGraus(radianos: Double): Double;
    procedure AssemblyGrauRadiano(var valor: Double);
    procedure AssemblyRadianoGrau(var valor: Double);

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

procedure TForm1.Button26Click(Sender: TObject);
begin
  Edit1.Text := FloatToStr(Pi);
end;

// Função para limpar a caixa de texto ao clicar no botão 'C'
procedure TForm1.Button32Click(Sender: TObject);
begin
  Edit1.Text := '';
end;

procedure TForm1.chkInversaChange(Sender: TObject);
begin

end;

// Definição da precendência das operações
function TForm1.Precedence(op: string): integer;
begin
  case op of
    '~': Precedence := 6; // troca de sinal
    'sqrt', 'y': Precedence := 5; // raiz quadrada
    'log', 'lan': Precedence := 5; // log  e log na base e
    'cos', 'sin', 'tan', 'arcsin', 'arccos', 'arctan': Precedence := 5; // cosseno, seno e tangente e as inversas das mesmas
    '^': Precedence := 5; // potência
    '*', '/': Precedence := 4;
    '+', '-': Precedence := 3;
    '<', '>': Precedence := 2; // não há implementação de < ou > na nossa calculadora
    '(': Precedence := 1;
    ')': Precedence := 0;
  else
    Precedence := -1;
  end;
end;

function TForm1.ehOperacaoEsp(op: string): Boolean;
  var
    j: Integer;
    operacoesEspeciais: array of string;
  begin
    operacoesEspeciais := ['sqrt', 'log', 'sin', 'cos', 'tan', 'arcsin', 'arccos', 'arctan'];
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
  tempNum: string;     // variável temporária para acumular os dígitos de um número (necessário para não separar números com 2 ou mais dígitos)
  tempOp: string;      // variável temporária para acumular os caracteres que compõem o nome de uma função (ex: 's', 'q', 'r' e 't' = sqrt)

begin
  IniciarPilhaChar(P1);
  L1 := TStringList.Create;
  tempNum := '';
  tempOp := '';
  expressao := StringReplace(expressao, 'x^y', '^', [rfReplaceAll]);
  expressao := StringReplace(expressao, 'x^2', '^2', [rfReplaceAll]);
  expressao := StringReplace(expressao, 'ysqrt', 'y', [rfReplaceAll]);
  expressao := StringReplace(expressao, 'pi', FloatToStr(Pi), [rfReplaceAll]);

  try
    i := 1;
    while i <= Length(expressao) do
    begin
      ch := expressao[i];

      if ch in ['0'..'9', ','] then
      begin
        tempNum := tempNum + ch; // Acumula o número
      end
      else
      begin
        if tempNum <> '' then
        begin
          L1.Add(tempNum); // Adiciona o número acumulado à lista
          tempNum := '';
        end;

        if ch in ['a'..'z', 'A'..'Z'] then
        begin
          tempOp := tempOp + ch;   // Acumula a operação especial
          if ehOperacaoEsp(tempOp) then
          begin
            while (not PilhaCharVazia(P1)) and (Precedence(P1.dado[P1.topo]) >= Precedence(tempOp)) do
            begin
              L1.Add(PopChar(P1)); // desempilha operadores
            end;
            PushChar(P1, tempOp[1]);
            tempOp := '';
          end;
        end
        else
        begin
          if tempOp <> '' then
          begin
            PushChar(P1, tempOp[1]); // Empilha a operação especial
            tempOp := '';
          end;

          case ch of
            '(':
              begin
                PushChar(P1, ch);
              end;
            ')':
              begin
                while (not PilhaCharVazia(P1)) and (P1.dado[P1.topo] <> '(') do
                begin
                  L1.Add(PopChar(P1));
                end;
                PopChar(P1); // remove '(' da pilha
              end;
            else
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
      L1.Add(tempNum); // Adiciona o número acumulado restante à lista
    end;

    while not PilhaCharVazia(P1) do
    begin
      L1.Add(PopChar(P1));
    end;

    Result := L1.DelimitedText;

  finally
    L1.Free;
  end;
end;

function TForm1.ehOperador(s: string): Boolean;
begin
  Result := s[1] in ['+', '-', '*', '/', '^'];
end;

function TForm1.ehLetraOuDigito(c: Char): Boolean;
begin
  Result := c in ['0'..'9', 'a'..'z', 'A'..'Z'];
end;

procedure TForm1.ButtonEqualsClick(Sender: TObject);
var
  expressao, posfixa: string;
  valor: Double;
begin
  expressao := Edit1.Text;
  posfixa := InfixToPostfix(expressao);
  valor := AvaliarNP(posfixa);
  Edit2.Text := FloatToStr(valor);
end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
  Edit1.Clear;
  Edit2.Clear;
end;

procedure TForm1.ButtonClick(Sender: TObject);
begin
  Edit1.Text := Edit1.Text + TButton(Sender).Caption;
end;

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
  Result := pilha.dado[pilha.topo];
  Dec(pilha.topo);
  SetLength(pilha.dado, pilha.topo + 1);
end;

function TForm1.PilhaCharVazia(const pilha: TPilhaChar): Boolean;
begin
  Result := pilha.topo = -1;
end;

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
  Result := pilha.dado[pilha.topo];
  Dec(pilha.topo);
  SetLength(pilha.dado, pilha.topo + 1);
end;

function TForm1.PilhaDoubleVazia(const pilha: TPilhaDouble): Boolean;
begin
  Result := pilha.topo = -1;
end;

function TForm1.GrausParaRadianos(graus: Double): Double;
begin
  Result := graus * (Pi / 180);
end;

function TForm1.RadianosParaGraus(radianos: Double): Double;
begin
  Result := radianos * (180 / Pi);
end;

procedure TForm1.Troca(var A, B: Double);
var
  temp: Double;
begin
  temp := A;
  A := B;
  B := temp;
end;

function TForm1.AvaliarNP(expressao: string): Double;
var
  pilha: TPilhaDouble;
  tokens: TStringList;
  token: string;
  i: integer;
  x, y: Double;
begin
  IniciarPilhaDouble(pilha);
  tokens := TStringList.Create;
  tokens.Delimiter := ' ';
  tokens.DelimitedText := expressao;

  try
    for i := 0 to tokens.Count - 1 do
    begin
      token := tokens[i];
      if TryStrToFloat(token, x) then
      begin
        PushDouble(pilha, x);
      end
      else if ehOperador(token) then
      begin
        y := PopDouble(pilha);
        x := PopDouble(pilha);
        case token of
          '+': PushDouble(pilha, x + y);
          '-': PushDouble(pilha, x - y);
          '*': PushDouble(pilha, x * y);
          '/': PushDouble(pilha, x / y);
          '^': PushDouble(pilha, Power(x, y));
        end;
      end
      else if ehOperacaoEsp(token) then
      begin
        x := PopDouble(pilha);
        if chkGraus.Checked then
        begin
          AssemblyRadianoGrau(x);
        end;
        case token of
          'sqrt': PushDouble(pilha, sqrt(x));
          'log': PushDouble(pilha, ln(x));
          'sin': PushDouble(pilha, sin(x));
          'cos': PushDouble(pilha, cos(x));
          'tan': PushDouble(pilha, tan(x));
          'arcsin': PushDouble(pilha, arcsin(x));
          'arccos': PushDouble(pilha, arccos(x));
          'arctan': PushDouble(pilha, arctan(x));
        end;
        if chkGraus.Checked then
        begin
          AssemblyGrauRadiano(x);
        end;
      end;
    end;
    Result := PopDouble(pilha);
  finally
    tokens.Free;
  end;
end;

procedure TForm1.AssemblyGrauRadiano(var valor: Double);
var
  constante: Double;
begin   
  constante := Pi/180.0;
  asm
    fld valor
    fmul constante // Pi / 180
    fstp valor
  end;
end;

procedure TForm1.AssemblyRadianoGrau(var valor: Double);
var
  constante: Double;
begin
  constante := 180.0/Pi;
  asm
    fld valor
    fmul constante // 180 / Pi
    fstp valor
  end;
end;

end.

