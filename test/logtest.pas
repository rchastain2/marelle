program logtest;
{$mode objfpc}{$h+}
uses game, computer, log;
var
  g: tgame;
  a: computeractionty;
  n: integer;
begin
  randseed := 12345;
  writelog('** Test', true);
  g := tgame.create();
  g.place(0);
  g.place(0);
  n := 0;
  while (g.phase <> ph_over) and (n < 400) do
  begin
    a := chooseaction(g);
    if a.target < 0 then break;
    case g.phase of
      ph_place: g.place(a.target);
      ph_move: g.move(a.source, a.target);
      ph_remove: g.remove(a.target);
    end;
    inc(n);
  end;
  writeln('actions: ', n, ' phase over: ', g.phase = ph_over);
  g.free;
end.
