unit Unit2;

interface

uses
  Classes, SysUtils;

type
  TPolonesa = class
  private
    function GetTipoToken(const TokenAtual: string): Integer;
    function Precedencia(const A, B: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function ConversaoNotacao(ExpressaoOriginal: TStringList): TStringList;
    function CalcularPolonesa(FilaExp: TStringList; IsRadiano: Integer): string;
  end;

implementation

constructor TPolonesa.Create;
begin
  inherited Create;
end;

destructor TPolonesa.Destroy;
begin
  inherited Destroy;
end;

function TPolonesa.ConversaoNotacao(ExpressaoOriginal: TStringList): TStringList;
var
  TipoToken: Integer;
  PilhaAuxiliar, FilaSaida: TStringList;
  TokenAtual, TopoPilha: string;
  PosiAtual: Integer;
begin
  PilhaAuxiliar := TStringList.Create;
  FilaSaida := TStringList.Create;
  PosiAtual := 0;

  try
    while PosiAtual < ExpressaoOriginal.Count do
    begin
      TokenAtual := ExpressaoOriginal[PosiAtual];
      Inc(PosiAtual);

      if TokenAtual = '' then
        Continue;

      TipoToken := GetTipoToken(TokenAtual);

      case TipoToken of
        _NUMERO:
          begin
            if TokenAtual[1] = _PI then
              TokenAtual := FloatToStr(CONSTPI);
            FilaSaida.Add(TokenAtual);
          end;
        _NUMEROSINAL:
          begin
            TopoPilha := _OP;
            PilhaAuxiliar.Add(TopoPilha);
            PilhaAuxiliar.Add(Copy(TokenAtual, 2, Length(TokenAtual) - 1));
          end;
        _OPERADOR:
          begin
            if PilhaAuxiliar.Count = 0 then
              PilhaAuxiliar.Add(TokenAtual)
            else
            begin
              while PilhaAuxiliar.Count > 0 do
              begin
                TopoPilha := PilhaAuxiliar[PilhaAuxiliar.Count - 1];
                if TopoPilha[1] = '(' then
                  Break;
                if (TokenAtual[1] = '^') and (Precedencia(TokenAtual, TopoPilha) > 0) then
                begin
                  FilaSaida.Add(TopoPilha);
                  PilhaAuxiliar.Delete(PilhaAuxiliar.Count - 1);
                end
                else if Precedencia(TokenAtual, TopoPilha) >= 0 then
                begin
                  FilaSaida.Add(TopoPilha);
                  PilhaAuxiliar.Delete(PilhaAuxiliar.Count - 1);
                end
                else
                  Break;
              end;
              PilhaAuxiliar.Add(TokenAtual);
            end;
          end;
        _FUNCAO:
          begin
            PilhaAuxiliar.Add(TokenAtual);
            TokenAtual := _OP;
            PilhaAuxiliar.Add(TokenAtual);
          end;
        _ABRIR_PARENTESES:
          PilhaAuxiliar.Add(TokenAtual);
        _FECHAR_PARENTESES:
          begin
            TopoPilha := PilhaAuxiliar[PilhaAuxiliar.Count - 1];
            while TopoPilha[1] <> _OP do
            begin
              FilaSaida.Add(TopoPilha);
              PilhaAuxiliar.Delete(PilhaAuxiliar.Count - 1);
              TopoPilha := PilhaAuxiliar[PilhaAuxiliar.Count - 1];
            end;
            PilhaAuxiliar.Delete(PilhaAuxiliar.Count - 1);
            if PilhaAuxiliar.Count = 0 then
              Break;
            TopoPilha := PilhaAuxiliar[PilhaAuxiliar.Count - 1];
            if GetTipoToken(TopoPilha) = _FUNCAO then
            begin
              FilaSaida.Add(TopoPilha);
              PilhaAuxiliar.Delete(PilhaAuxiliar.Count - 1);
            end;
          end;
      end;
    end;

    while PilhaAuxiliar.Count > 0 do
    begin
      FilaSaida.Add(PilhaAuxiliar[PilhaAuxiliar.Count - 1]);
      PilhaAuxiliar.Delete(PilhaAuxiliar.Count - 1);
    end;
  finally
    Result := FilaSaida;
    PilhaAuxiliar.Free;
  end;
end;

function TPolonesa.Precedencia(const A, B: string): Integer;
var
  PrecedenciaA, PrecedenciaB: Integer;
  Operador: Char;
begin
  Operador := A[1];
  if (Operador = _ADD) or (Operador = _SUB) then
    PrecedenciaA := 1
  else if (Operador = _MUL) or (Operador = _DIV) then
    PrecedenciaA := 2
  else if (Operador = _XPOWY) or (Operador = _POW2) then
    PrecedenciaA := 3
  else if Operador = _FAT then
    PrecedenciaA := 4;

  Operador := B[1];
  if (Operador = _ADD) or (Operador = _SUB) then
    PrecedenciaB := 1
  else if (Operador = _MUL) or (Operador = _DIV) then
    PrecedenciaB := 2
  else if Operador = _XPOWY then
    PrecedenciaB := 3
  else if Operador = _FAT then
    PrecedenciaB := 4;

  Result := PrecedenciaB - PrecedenciaA;
end;

function TPolonesa.GetTipoToken(const TokenAtual: string): Integer;
var
  PrimeiroCharString: Char;
begin
  PrimeiroCharString := TokenAtual[1];

  if PrimeiroCharString = '(' then
    Exit(_NUMEROSINAL);

  if (PrimeiroCharString >= '0') and (PrimeiroCharString <= '9') or
     (PrimeiroCharString = _PI) or (PrimeiroCharString = '-') then
    Exit(_NUMERO);

  if PrimeiroCharString = _OP then
    Exit(_ABRIR_PARENTESES);

  if PrimeiroCharString = _CP then
    Exit(_FECHAR_PARENTESES);

  if (PrimeiroCharString >= 'a') and (PrimeiroCharString <= 'i') then
    Exit(_OPERADOR);

  Result := _FUNCAO;
end;

function TPolonesa.CalcularPolonesa(FilaExp: TStringList; IsRadiano: Integer): string;
var
  PilhaDeCalculo: TStringList;
  TokenAtual, OperadorA, OperadorB: string;
  Operacoes: TAssemblyFunctions;
  TipoToken: Integer;
begin
  PilhaDeCalculo := TStringList.Create;

  try
    while FilaExp.Count > 0 do
    begin
      TokenAtual := FilaExp[0];
      FilaExp.Delete(0);
      TipoToken := GetTipoToken(TokenAtual);

      case TipoToken of
        _NUMERO:
          PilhaDeCalculo.Add(TokenAtual);
        _OPERADOR, _FUNCAO:
          begin
            if (TokenAtual[1] <> _FAT) and (TokenAtual[1] <> _POW2) then
            begin
              OperadorB := PilhaDeCalculo[PilhaDeCalculo.Count - 1];
              PilhaDeCalculo.Delete(PilhaDeCalculo.Count - 1);
            end;

            if (TokenAtual[1] = _NROOT) or (TokenAtual[1] = _XPOWY) and (TipoToken = _FUNCAO) then
            begin
              OperadorB := PilhaDeCalculo[PilhaDeCalculo.Count - 1];
              PilhaDeCalculo.Delete(PilhaDeCalculo.Count - 1);
            end;

            OperadorA := PilhaDeCalculo[PilhaDeCalculo.Count - 1];
            PilhaDeCalculo.Delete(PilhaDeCalculo.Count - 1);

            case TokenAtual[1] of
              _ADD:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Soma(StrToFloat(OperadorA), StrToFloat(OperadorB))));
              _MUL:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Multiplicacao(StrToFloat(OperadorA), StrToFloat(OperadorB))));
              _SUB:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Subtracao(StrToFloat(OperadorA), StrToFloat(OperadorB))));
              _DIV:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Divisao(StrToFloat(OperadorA), StrToFloat(OperadorB))));
              _POW2:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.XElevadoAoQuadrado(StrToFloat(OperadorA))));
              _XPOWY:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.XElevadoAy(StrToFloat(OperadorA), StrToFloat(OperadorB))));
              _FAT:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Fatorial(StrToFloat(OperadorA))));
              _EXP:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.XElevadoAy(Euler, StrToFloat(OperadorA))));
              _TG:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Tg(StrToFloat(OperadorA), IsRadiano)));
              _LN:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Log(StrToFloat(OperadorA), Euler)));
              _SIN:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Sin(StrToFloat(OperadorA), IsRadiano)));
              _COS:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Cos(StrToFloat(OperadorA), IsRadiano)));
              _LOG:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Log(StrToFloat(OperadorA), 10)));
              _NROOT:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.RaizNdeX(StrToFloat(OperadorA), StrToFloat(OperadorB))));
              _SQRT:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Sqrt(StrToFloat(OperadorA))));
              _ARCTG:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Arctg(StrToFloat(OperadorA), IsRadiano)));
              _ARCCOS:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Arccos(StrToFloat(OperadorA), IsRadiano)));
              _ARCSIN:
                PilhaDeCalculo.Add(FloatToStr(Operacoes.Arcsin(StrToFloat(OperadorA), IsRadiano)));
            end;
          end;
      end;
    end;

    Result := PilhaDeCalculo[PilhaDeCalculo.Count - 1];
  finally
    PilhaDeCalculo.Free;
  end;
end;

end.

