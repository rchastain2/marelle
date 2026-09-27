program marelle;

{$mode objfpc}{$h+}
{$ifdef mswindows}
{$apptype gui}
{$R marelle.rc}
{$endif}

uses
{$ifdef unix}
  cthreads,
{$endif}
  msegui, main;

begin
  application.createform(tmainfo, mainfo);
  application.run;
end.
