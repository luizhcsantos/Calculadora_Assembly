unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Interfaces, Forms, StdCtrls, SysUtils, Classes;

type
  TForm1 = class(TForm)
    EditInfixa: TEdit;
    EditPosfixa: TEdit;
    ButtonConvert: TButton;
    procedure ButtonConvertClick(Sender: TObject);
  private
    procedure Criapilha();
    procedure Empilha(c: char);
    function Desempilha(): char;
    function InfixaParaPosfixa(inf: string): string;
  public
    pilha: record
      items: array of char;
      top: Integer;
    end;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.Criapilha();
begin
  SetLength(pilha.items, 100);  // Ajuste o tamanho conforme necessário
  pilha.top := -1;
end;

procedure TForm1.Empilha(c: char);
begin
  Inc(pilha.top);
  pilha.items[pilha.top] := c;
end;

function TForm1.Desempilha(): char;
begin
  if pilha.top = -1 then
    raise Exception.Create('Pilha vazia');
  Result := pilha.items[pilha.top];
  Dec(pilha.top);
end;

function TForm1.InfixaParaPosfixa(inf: string): string;
var
  n, i, j: Integer;
  posf: string;
  x: char;
begin
  n := Length(inf);
  SetLength(posf, n + 1);
  Criapilha();
  Empilha('(');

  j := 1;
  for i := 1 to n do
  begin
    case inf[i] of
      '(': Empilha(inf[i]);
      ')': begin
             x := Desempilha();
             while x <> '(' do
             begin
               posf[j] := x;
               Inc(j);
               x := Desempilha();
             end;
           end;
      '+', '-': begin
                  x := Desempilha();
                  while (x <> '(') and (x <> #0) do
                  begin
                    posf[j] := x;
                    Inc(j);
                    x := Desempilha();
                  end;
                  Empilha(x);
                  Empilha(inf[i]);
                end;
      '*', '/': begin
                  x := Desempilha();
                  while (x <> '(') and (x <> '+') and (x <> '-') and (x <> #0) do
                  begin
                    posf[j] := x;
                    Inc(j);
                    x := Desempilha();
                  end;
                  Empilha(x);
                  Empilha(inf[i]);
                end;
      else begin
             posf[j] := inf[i];
             Inc(j);
           end;
    end;
  end;

  SetLength(posf, j);  // Ajuste o comprimento da string de saída
  Result := posf;
end;

procedure TForm1.ButtonConvertClick(Sender: TObject);
var
  infixa, posfixa: string;
begin
  infixa := EditInfixa.Text;
  posfixa := InfixaParaPosfixa(infixa);
  EditPosfixa.Text := posfixa;
end;

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  with Form1 do
  begin
    Caption := 'Conversor de Infixa para Posfixa';
    Width := 400;
    Height := 200;

    EditInfixa := TEdit.Create(Form1);
    EditInfixa.Parent := Form1;
    EditInfixa.Top := 20;
    EditInfixa.Left := 20;
    EditInfixa.Width := 360;

    EditPosfixa := TEdit.Create(Form1);
    EditPosfixa.Parent := Form1;
    EditPosfixa.Top := 60;
    EditPosfixa.Left := 20;
    EditPosfixa.Width := 360;

    ButtonConvert := TButton.Create(Form1);
    ButtonConvert.Parent := Form1;
    ButtonConvert.Caption := 'Converter';
    ButtonConvert.Top := 100;
    ButtonConvert.Left := 20;
    ButtonConvert.OnClick := @ButtonConvertClick;
  end;
  Application.Run;
end.

