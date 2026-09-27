
program factory;

{$mode objfpc}{$h+}

uses
  sysutils;

const
  pointcount = 24;

type
  axisty = (ax_x, ax_y, ax_z);
  cubety = array[-1..1, -1..1, -1..1] of integer;

var
  cube: cubety;
  px, py, pz: array[0..pointcount - 1] of integer;
  count: integer;

function valid(const x, y, z: integer): boolean;
begin
  result := (abs(x) <= 1) and (abs(y) <= 1) and (abs(z) <= 1) and ((x <> 0) or (y <> 0));
end;

function crossing(const x, y: integer): boolean;
begin
  result := (x and y) = 0;
end;

procedure build();
var
  gx, gy, x, y, z, d: integer;
begin
  for x := -1 to 1 do
    for y := -1 to 1 do
      for z := -1 to 1 do
        cube[x, y, z] := -1;
  
  count := 0;
  for gy := 1 to 7 do
    for gx := 1 to 7 do
    begin
      d := abs(gx - 4);
      if abs(gy - 4) > d then
        d := abs(gy - 4);
      if d = 0 then
        continue;
      x := (gx - 4) div d;
      y := (gy - 4) div d;
      if abs(gx - 4) mod d + abs(gy - 4) mod d <> 0 then
        continue;
      z := d - 2;
      cube[x, y, z] := count;
      px[count] := x;
      py[count] := y;
      pz[count] := z;
      inc(count);
    end;
end;

function shift(const i: integer; const axis: axisty; const delta: integer): integer;
var
  x, y, z: integer;
begin
  x := px[i];
  y := py[i];
  z := pz[i];
  case axis of
    ax_x: inc(x, delta);
    ax_y: inc(y, delta);
    ax_z: inc(z, delta);
  end;
  if valid(x, y, z) then
    result := cube[x, y, z]
  else
    result := -1;
end;

function linked(const i: integer; const axis: axisty): boolean;
begin
  result := (axis <> ax_z) or crossing(px[i], py[i]);
end;

function neighbourrow(const i: integer): string;
var
  list: array[0..3] of integer;
  axis: axisty;
  n, j, k, t, delta: integer;
begin
  for j := 0 to 3 do
    list[j] := -1;
  n := 0;
  for axis := low(axisty) to high(axisty) do
    if linked(i, axis) then
    begin
      delta := -1;
      while delta <= 1 do
      begin
        k := shift(i, axis, delta);
        if k >= 0 then
        begin
          list[n] := k;
          inc(n);
        end;
        inc(delta, 2);
      end;
    end;
  for j := 1 to n - 1 do
    for k := n - 1 downto j do
      if list[k - 1] > list[k] then
      begin
        t := list[k - 1];
        list[k - 1] := list[k];
        list[k] := t;
      end;
  result := format('(%d, %d, %d, %d)', [list[0], list[1], list[2], list[3]]);
end;

function millpair(const i: integer; const axis: axisty; out a, b: integer): boolean;
var
  c, k: integer;
begin
  result := linked(i, axis);
  if not result then
    exit;
  a := -1;
  b := -1;
  for c := -1 to 1 do
  begin
    case axis of
      ax_x: if not valid(c, py[i], pz[i]) then exit(false) else k := cube[c, py[i], pz[i]];
      ax_y: if not valid(px[i], c, pz[i]) then exit(false) else k := cube[px[i], c, pz[i]];
      ax_z: k := cube[px[i], py[i], c];
    end;
    if k = i then
      continue;
    if a < 0 then
      a := k
    else
      b := k;
  end;
  if a > b then
  begin
    k := a;
    a := b;
    b := k;
  end;
end;

function linerow(const i: integer): string;
var
  axis: axisty;
  a, b: integer;
begin
  result := '';
  for axis := low(axisty) to high(axisty) do
    if millpair(i, axis, a, b) then
    begin
      if result <> '' then
        result := result + ', ';
      result := result + format('%d, %d', [a, b]);
    end;
  result := '(' + result + ')';
end;

function coordrow(const i: integer): string;
begin
  result := format('(%d, %d)', [4 + px[i] * (pz[i] + 2), 4 + py[i] * (pz[i] + 2)]);
end;

procedure writetable(const aname, atype: string; const arow: integer);
var
  i: integer;
  s: string;
begin
  writeln('  ', aname, ': array[0..pointcount - 1', atype, ' of integer = (');
  for i := 0 to count - 1 do
  begin
    if i mod 3 = 0 then
      write('    ');
    case arow of
      0: s := coordrow(i);
      1: s := linerow(i);
      2: s := neighbourrow(i);
    end;
    write(s);
    if i < count - 1 then
      write(',');
    if (i mod 3 = 2) or (i = count - 1) then
      writeln()
    else
      write(' ');
  end;
  writeln('  );');
end;

begin
  build();
  if count <> pointcount then
  begin
    writeln(stderr, 'erreur : ', count, ' points');
    halt(1);
  end;
  writeln('const');
  writetable('coords', ', 0..1]', 0);
  writeln();
  writetable('lines', ', 0..3]', 1);
  writeln();
  writetable('neighbours', ', 0..3]', 2);
end.
