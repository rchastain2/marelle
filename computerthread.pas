unit computerthread;

{$mode objfpc}{$h+}

interface

uses
  mseclasses,
  msethread,
  game,
  computer;

const
  thinkingdelay = 1500;

type
  tcomputerthread = class(tmsethread)
  private
    fgame: tgame;
    fclient: tmsecomponent;
    ftag: integer;
    fturn: computerturnty;
    fdone: boolean;
  protected
    function execute(thread: tmsethread): integer; override;
  public
    constructor create(const agame: tgame; const aclient: tmsecomponent; const atag: integer); reintroduce;
    destructor destroy(); override;
    property turn: computerturnty read fturn;
    property done: boolean read fdone;
  end;

implementation

uses
  sysutils;

constructor tcomputerthread.create(const agame: tgame; const aclient: tmsecomponent; const atag: integer);
begin
  fgame := tgame.createcopy(agame);
  fclient := aclient;
  ftag := atag;
  inherited create();
end;

destructor tcomputerthread.destroy();
begin
  inherited;
  fgame.free;
end;

function tcomputerthread.execute(thread: tmsethread): integer;
var
  t: qword;
begin
  t := gettickcount64() + thinkingdelay;
  while (gettickcount64() < t) and not terminated do
    sleep(20);
  if not terminated then
  begin
    fturn := chooseturn(fgame);
    fdone := true;
    fclient.asyncevent(ftag);
  end;
  result := 0;
end;

end.
