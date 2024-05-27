unit Unit2;


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

  end;

implementation

{$R *.lfm}


function Precedence(op: char): integer;
begin
  case op of
    '^': Precedence := 5;
    '*', '/': Precedence := 4;
    '+', '-': Precedence := 3;
    '(': Precedence := 1;
  else
    Precedence := 0;
  end;
end;

function InfixToPostfix(expression: string): string;
var
  stack: TStringList;
  postfix: string;
  i: integer;
  ch: char;
begin
  stack := TStringList.Create;
  postfix := '';
  for i := 1 to Length(expression) do
  begin
    ch := expression[i];
    case ch of
      'a'..'z', 'A'..'Z', '0'..'9':
        postfix := postfix + ch;
      '(': // [^1^][1]
        stack.Add(ch);
      ')': //[^1^][1]
        begin
          while (stack.Count > 0) and (stack[stack.Count - 1] <> '(') do
          begin
            postfix := postfix + stack[stack.Count - 1];
            stack.Delete(stack.Count - 1);
          end;
          if stack.Count > 0 then
            stack.Delete(stack.Count - 1);
        end;
      '+', '-', '*', '/', '^':
        begin
          while (stack.Count > 0) and (Precedence(stack[stack.Count - 1][1]) >= Precedence(ch)) do

          begin
            postfix := postfix + stack[stack.Count - 1];
            stack.Delete(stack.Count - 1);
          end;
          stack.Add(ch);
        end;
    end;
  end;
  while stack.Count > 0 do
  begin
    postfix := postfix + stack[stack.Count - 1];
    stack.Delete(stack.Count - 1);
  end;
  stack.Free;
  Result := postfix;
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

