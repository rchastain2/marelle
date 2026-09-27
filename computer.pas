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

function chooseaction(const agame: tgame): computeractionty;

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

initialization
  randomize();
end.
