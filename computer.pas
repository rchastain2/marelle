unit computer;

{$mode objfpc}{$h+}

interface

uses
  game;

type
  computeractionty = record
    source: integer;
    target: integer;
  end;

  computerturnty = record
    source: integer;
    target: integer;
    capture: integer;
  end;

function chooseaction(const agame: tgame): computeractionty;
function chooseturn(const agame: tgame): computerturnty;

implementation

function chooseaction(const agame: tgame): computeractionty;
var
  candidates: array of computeractionty;
  count, i, j: integer;

  procedure add(const asource, atarget: integer);
  begin
    if count = length(candidates) then
      setlength(candidates, 2 * count + 16);
    candidates[count].source := asource;
    candidates[count].target := atarget;
    inc(count);
  end;

begin
  count := 0;
  case agame.phase of
    ph_place:
      for i := 0 to pointcount - 1 do
        if agame.points[i] = 0 then
          add(-1, i);
    ph_move:
      for i := 0 to pointcount - 1 do
        if agame.points[i] = agame.player then
          for j := 0 to pointcount - 1 do
            if agame.maymove(i, j) then
              add(i, j);
    ph_remove:
      for i := 0 to pointcount - 1 do
        if agame.maytake(i) then
          add(-1, i);
  end;
  if count = 0 then
  begin
    result.source := -1;
    result.target := -1;
  end
  else
    result := candidates[random(count)];
end;

function chooseturn(const agame: tgame): computerturnty;
var
  a: computeractionty;
  p: integer;
begin
  p := agame.player;
  a := chooseaction(agame);
  result.source := a.source;
  result.target := a.target;
  result.capture := -1;
  if a.target < 0 then
    exit;
  case agame.phase of
    ph_place:
      agame.place(a.target);
    ph_move:
      agame.move(a.source, a.target);
  end;
  if (agame.phase = ph_remove) and (agame.player = p) then
    result.capture := chooseaction(agame).target;
end;

initialization
  randomize();
end.
