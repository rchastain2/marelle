unit log;

{$mode objfpc}{$h+}

interface

procedure writelog(const aline: string; const arewrite: boolean = false);

implementation

uses
  sysutils;

var
  logname: string;

procedure writelog(const aline: string; const arewrite: boolean);
var
  f: text;
begin
  assign(f, logname);
  {$i-}
  if fileexists(logname) and not arewrite then
    append(f)
  else
    rewrite(f);
  {$i+}
  if ioresult <> 0 then
    exit;
  writeln(f, formatdatetime('hh:nn:ss:zzz', now), ' ', aline);
  close(f);
end;

initialization
  logname := changefileext(paramstr(0), '.log');
end.
