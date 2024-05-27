program Converter;
var
  indexp, indpol, topo: integer;
  exp: array[1..100] of char; // Suponha que exp é um array de caracteres
  pol: array[1..100] of char; // Suponha que pol é um array de caracteres
  pilha: array[1..100] of char; // Suponha que pilha é um array de caracteres
  fim: integer; // Suponha que fim é um inteiro
  operador: char;
begin
  indexp := 1;
  indpol := 0;
  topo := 0;
  
  // Enquanto indexp for menor ou igual a fim
  while indexp <= fim do
  begin
    // Se exp[indexp] é um operando
    if exp[indexp] in ['0'..'9', 'A'..'Z', 'a'..'z'] then
    begin
      indpol := indpol + 1;
      pol[indpol] := exp[indexp];
    end
    // Se exp[indexp] é um operador
    else if exp[indexp] in ['+', '-', '*', '/'] then
    begin
      topo := topo + 1;
      pilha[topo] := exp[indexp];
    end
    // Se exp[indexp] é ")"
    else if exp[indexp] = ')' then
    begin
      // Se topo não for 0
      if topo <> 0 then
      begin
        operador := pilha[topo];
        topo := topo - 1;
        indpol := indpol + 1;
        pol[indpol] := operador;
      end
      else
        writeln('Expressão errada');
    end;
    indexp := indexp + 1;
  end;
end.
