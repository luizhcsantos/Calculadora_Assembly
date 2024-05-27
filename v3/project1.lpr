program Project1;

{$mode objfpc}{$H+}

uses
  crt,
  Classes,
  SysUtils;

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
      '(':
        stack.Add(ch);
      ')':
        begin
          while (stack.Count > 0) and (stack[stack.Count - 1][1] <> '(') do
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
  WriteLn('Expressão infixa: ');
  WriteLn(InfixToPostfix('(2+3)*5'));
  ReadLn;
  readkey;
end.

