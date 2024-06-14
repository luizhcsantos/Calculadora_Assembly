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

  TPilhaString = record
    dado: array of string;
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
    procedure IniciarPilhaString(var pilha: TPilhaString);
    procedure PushString(var pilha: TPilhaString; valor: string);
    function PopString(var pilha: TPilhaString): String;
    function PilhaStringVazia(const pilha: TPilhaString): Boolean;

    procedure IniciarPilhaDouble(var pilha: TPilhaDouble);
    procedure PushDouble(var pilha: TPilhaDouble; valor: Double);
    function PopDouble(var pilha: TPilhaDouble): Double;
    function PilhaDoubleVazia(const pilha: TPilhaDouble): Boolean;

    function InfixToPostfix(expressao: string): string;
    function ehLetraOuDigito(c: Char): Boolean;
    function Precedence(op: string): integer;
    function ehOperador(s: string): Boolean;
    function ehOperacaoEspecial(op: string): Boolean;

    procedure Troca(var A, B: Double);
    procedure chkGrausClick(Sender: TObject);
    procedure chkRadianosClick(Sender: TObject);
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
  Edit1.Text := FloatToSTr(Pi);
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
    'fat': Precedence := 5; // fatorial
    'sqrt', 'y': Precedence := 5; // raiz quadrada  e raiz n-ésima
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

function TForm1.ehOperacaoEspecial(op: string): Boolean;
  var
    j: Integer;
    operacoesEspeciais: array of string;
  begin
    operacoesEspeciais := ['sqrt', 'log', 'fat', 'sin', 'cos', 'tan', 'arcsin', 'arccos', 'arctan'];
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
  P1: TPilhaString;      // pilha para armazenar os operadores
  L1: TStringList;     // lista para armazenar os valores da operação
  i: integer;
  ch: char;
  tempNum: string;     // variável temporária para acumular os dígitos de um número (necessário para não separar números com 2 ou mais dígitos)
  tempOp: string;      // variável temporária para acumular os caracteres que compõem o nome de uma função (ex: 's', 'q', 'r' e 't' = sqrt)



begin
  IniciarPilhaString(P1);
  L1 := TStringList.Create;
  tempNum := '';
  tempOp := '';
  expressao := StringReplace(expressao, 'x^y', '^', [rfReplaceAll]);
  expressao := StringReplace(expressao, 'x^2', '^2', [rfReplaceAll]);
  expressao := StringReplace(expressao, 'ysqrt', 'y', [rfReplaceAll]);
  expressao := StringReplace(expressao, 'pi', FloatToStr(Pi), [rfReplaceAll]);
  expressao := StringReplace(expressao, 'n!', 'fat', [rfReplaceAll]);

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
          if ehOperacaoEspecial(tempOp) then
          begin
            while (not PilhaStringVazia(P1)) and (Precedence(P1.dado[P1.topo]) >= Precedence(tempOp[1])) do
            begin
              L1.Add(PopString(P1));
            end;
            PushString(P1, tempOp); // Empilha a operação especial
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
              PushString(P1, ch);
            ')':
              begin
                while (not PilhaStringVazia(P1)) and (P1.dado[P1.topo] <> '(') do
                begin
                  L1.Add(PopString(P1));
                end;
                if (not PilhaStringVazia(P1)) then
                  PopString(P1); // Remover '(' da pilha
              end;

            '+', '-', '*', '/', '^', '~', 'y':
              begin
                while (not PilhaStringVazia(P1)) and (Precedence(P1.dado[P1.topo]) >= Precedence(ch)) do
                begin
                  L1.Add(PopString(P1));
                end;
                PushString(P1, ch);
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

    while (not PilhaStringVazia(P1)) do
    begin
      L1.Add(PopString(P1));
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
  operacoesEspeciais := ['sqrt', 'log', 'sin', 'cos', 'arcsin', 'arccos', 'arctan'];

  // Obtém o dígito do botão clicado
  numeroDigitado := (Sender as TButton).Caption;

  // Verifica se o texto atual do Edit1 é vazio
  if Edit1.Text = '' then
  begin
    if chkInversa.Checked and MatchStr(numeroDigitado, ['sin', 'cos', 'tan']) then
       Edit1.Text := 'arc' + numeroDigitado + ' '
    else
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
      if chkInversa.Checked then
      begin
        if MatchStr(numeroDigitado, ['sin', 'cos', 'tan']) then
        begin
           numeroDigitado := 'arc' + operacoesEspeciais[i] + ' ';
        end
      end

      else
      begin
           numeroDigitado := operacoesEspeciais[i] + ' ';
      end;

      isOperacaoEspecial := True;
      Break;
    end;
  end;

  if not isOperacaoEspecial and ehOperador(numeroDigitado) then
  begin
    // Se for outro operador, adicione um espaço antes do operador
    numeroDigitado := ' ' + numeroDigitado;
  end;


  if textoAtual[tamanho] in ['+', '-', '*', '/', '~', 'y'] then
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
  fat: integer;
begin
  IniciarPilhaDouble(pilha);
  tokens := SplitString(expressao, ' ');

  foundNil := False;  
  base := 10;

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
    //  if (not PilhaDoubleVazia(pilha)) then
    //  begin


        if token = '~' then
        begin
          op1 := PopDouble(pilha);
          asm
           fld op1
           fchs
           fstp op1
          end;
          PushDouble(pilha, op1);
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
            begin
               Troca(op2, op1);
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
                 end

            end
            else if (token = 'y') or (token = '2')then // x^y = op1^(1/op2)
            begin

              x := 1/op1;
             asm
               fld op2
               fld1
               fld x
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
            end
              end;

            PushDouble(pilha, op1);
       end;
    end
    //else
    //
    //end
    else if ehOperacaoEspecial(token) then
    begin
      if i + 1 < Length(tokens) then
      begin
        //Inc(i);
        if (ehOperacaoEspecial(token)) then
        //if TryStrToFloat(tokens[i], op1) then
        begin
          //PushDouble(pilha, op1);
          op1 := PopDouble(pilha);
          if chkGraus.Checked then
             op1 := DegToRad(op1);
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
          else if token = 'fat' then
          begin
            fat := Round(op1);
            asm
              finit
              fld1            // Carrega 1.0 no topo da pilha da FPU (st(0))
              fldz            // Carrega 0.0 no topo da pilha da FPU (st(0))
              mov ecx, fat // Move o valor inteiro da variável temporária para o registrador ecx

              @@loop:
              fld1            // Carrega 1.0 no topo da pilha da FPU (st(0))
              faddp st(1), st // Adiciona st(0) a st(1), armazena o resultado em st(1) e remove st(0)
              fmul st(1), st  // Multiplica st(1) por st(0)

              dec ecx         // Decrementa ecx
              jnz @@loop      // Se ecx não for zero, salta para @@loop

              fxch     // Armazena o valor de st(0) em fat
              fstp op1     // Armazena o valor de st(0) em op1
            end;

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
          begin
            // Obs: os valores de arctan estão no intervalo [-pi/2, pi/2]
           if chkInversa.Checked then
           asm
            fld op1
            fpatan
            fstp op1
           end;
           end
           else
           asm
            fld op1
            fsincos
	    fdivp st(1), st(0)
	    fstp op1
           end;


        // Converter o resultado de volta para graus se checkbox graus estiver marcado
        if chkGraus.Checked then
          AssemblyRadianoGrau(op1);
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
procedure TForm1.IniciarPilhaString(var pilha: TPilhaString);
begin
  SetLength(pilha.dado, 0);
  pilha.topo := -1;
end;

procedure TForm1.PushString(var pilha: TPilhaString; valor: string);
begin
  Inc(pilha.topo);
  SetLength(pilha.dado, pilha.topo + 1);
  pilha.dado[pilha.topo] := valor;
end;

function TForm1.PopString(var pilha: TPilhaString): string;
begin
  if pilha.topo < 0 then
    raise Exception.Create('Stack underflow');
  Result := pilha.dado[pilha.topo];
  Dec(pilha.topo);
end;

function TForm1.PilhaStringVazia(const pilha: TPilhaString): Boolean;
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
  Result := (s = '+') or (s = '-') or (s = '*') or (s = '/') or (s = '~') or (s = '^') or (s = 'y');
end;


procedure TForm1.Troca(var A, B: Double);
var
  Temp: Double;
begin
  Temp := A;
  A := B;
  B := Temp;
end;

function TForm1.GrausParaRadianos(graus: Double): Double;
begin
  Result := DegToRad(graus);
end;

function TForm1.RadianosParaGraus(radianos: Double): Double;
begin
  Result := RadToDeg(radianos);
end;

procedure TForm1.chkGrausClick(Sender: TObject);
begin
  if chkGraus.Checked then
    chkRadianos.Checked := False;
end;

procedure TForm1.chkRadianosClick(Sender: TObject);
begin
  if chkRadianos.Checked then
    chkGraus.Checked := False;
end;

procedure TForm1.AssemblyGrauRadiano(var valor: Double);
var
  constante: Double;
begin
  constante := 180.0;
  asm
    fld valor     // Load the value to convert
    fldpi        // Load pi
    fmulp st(1), st(0) // Multiply the value by pi
    fld constante // Load 180
    fdivp st(1), st(0) // Divide the result by 180
    fstp valor    // Store the result back to the variable
  end;
end;

procedure TForm1.AssemblyRadianoGrau(var valor: Double);
var
  constante: Double;
begin
  constante := 180.0;
  asm
    fld valor     // Load the value to convert
    fld constante // Load 180
    fmulp st(1), st(0) // Multiply the value by 180
    fldpi        // Load pi
    fdivp st(1), st(0) // Divide the result by pi
    fstp valor    // Store the result back to the variable
  end;
end;

function TForm1.ehLetraOuDigito(c: Char): Boolean;
begin
  Result := CharInSet(c, ['A'..'Z', 'a'..'z', '0'..'9']);
end;

end.

