program drawcube;

{$mode objfpc}{$h+}

uses
  sysutils, math;

const
  pointcount = 24;
  layercolors: array[-1..1] of string = ('#1f6fb2', '#2e9e44', '#c8372d');
  linkcolor = '#555555';
  gridcolor = '#b0b0b0';

type
  viewty = (vw_3d, vw_top);
  vecty = record
    u, v, depth: double;
  end;

var
  view: viewty;
  px, py, pz: array[0..pointcount - 1] of integer;
  count: integer;
  unitsize, originu, originv: double;
  width, height: integer;

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
  count := 0;
  for gy := 1 to 7 do
    for gx := 1 to 7 do
    begin
      d := max(abs(gx - 4), abs(gy - 4));
      if d = 0 then
        continue;
      if abs(gx - 4) mod d + abs(gy - 4) mod d <> 0 then
        continue;
      x := (gx - 4) div d;
      y := (gy - 4) div d;
      z := d - 2;
      px[count] := x;
      py[count] := y;
      pz[count] := z;
      inc(count);
    end;
end;

function project(const x, y, z: integer): vecty;
const
  yaw = -28 * pi / 180;
  pitch = 18 * pi / 180;
  spacing = 1.6;
var
  wx, wy, wz, rx, ry: double;
  s: integer;
begin
  if view = vw_top then
  begin
    s := z + 2;
    result.u := originu + x * s * unitsize;
    result.v := originv + y * s * unitsize;
    result.depth := -z;
  end
  else
  begin
    wx := x;
    wy := -y;
    wz := z * spacing;
    rx := wx * cos(yaw) - wy * sin(yaw);
    ry := wx * sin(yaw) + wy * cos(yaw);
    result.u := originu + rx * unitsize;
    result.v := originv - (wz * cos(pitch) + ry * sin(pitch)) * unitsize;
    result.depth := ry * cos(pitch) - wz * sin(pitch);
  end;
end;

function num(const a: double): string;
begin
  result := formatfloat('0.0', a, defaultformatsettings);
end;

procedure segment(const a, b: vecty; const acolor: string; const awidth: double; const adashed: boolean);
begin
  write(format('  <line x1="%s" y1="%s" x2="%s" y2="%s" stroke="%s" stroke-width="%s" stroke-linecap="round"',
    [num(a.u), num(a.v), num(b.u), num(b.v), acolor, num(awidth)]));
  if adashed then
    write(' stroke-dasharray="6 6"');
  writeln('/>');
end;

procedure text(const au, av: double; const asize: integer; const acolor, aanchor, atext: string; const abold: boolean);
begin
  write(format('  <text x="%s" y="%s" font-size="%d" fill="%s" text-anchor="%s" dominant-baseline="central" stroke="white" stroke-width="4" paint-order="stroke"',
    [num(au), num(av), asize, acolor, aanchor]));
  if abold then
    write(' font-weight="bold"');
  writeln('>', atext, '</text>');
end;

procedure drawgrid();
var
  x, y, z: integer;
begin
  for x := -1 to 1 do
    for y := -1 to 1 do
      for z := -1 to 1 do
      begin
        if x < 1 then
          if not (valid(x, y, z) and valid(x + 1, y, z)) then
            segment(project(x, y, z), project(x + 1, y, z), gridcolor, 1, true);
        if y < 1 then
          if not (valid(x, y, z) and valid(x, y + 1, z)) then
            segment(project(x, y, z), project(x, y + 1, z), gridcolor, 1, true);
        if z < 1 then
          if not crossing(x, y) or not valid(x, y, z) then
            segment(project(x, y, z), project(x, y, z + 1), gridcolor, 1, true);
      end;
end;

procedure drawlinks();
var
  i, j: integer;
  a, b: vecty;
begin
  for i := 0 to count - 1 do
    for j := i + 1 to count - 1 do
      if abs(px[i] - px[j]) + abs(py[i] - py[j]) + abs(pz[i] - pz[j]) = 1 then
      begin
        a := project(px[i], py[i], pz[i]);
        b := project(px[j], py[j], pz[j]);
        if pz[i] = pz[j] then
          segment(a, b, layercolors[pz[i]], 4, false)
        else if crossing(px[i], py[i]) then
          segment(a, b, linkcolor, 4, false);
      end;
end;

procedure drawcentres();
var
  z: integer;
  c: vecty;
begin
  for z := -1 to 1 do
  begin
    c := project(0, 0, z);
    writeln(format('  <circle cx="%s" cy="%s" r="7" fill="white" stroke="%s" stroke-width="2" stroke-dasharray="3 3"/>',
      [num(c.u), num(c.v), gridcolor]));
    if view = vw_top then
      break;
  end;
  if view = vw_top then
    text(c.u, c.v + 22, 13, '#808080', 'middle', '(0, 0, z)', false);
end;

procedure drawpoints();
var
  order: array[0..pointcount - 1] of integer;
  depths: array[0..pointcount - 1] of double;
  i, j, t: integer;
  c: vecty;
begin
  for i := 0 to count - 1 do
  begin
    order[i] := i;
    depths[i] := project(px[i], py[i], pz[i]).depth;
  end;
  for i := 1 to count - 1 do
    for j := count - 1 downto i do
      if depths[order[j - 1]] < depths[order[j]] then
      begin
        t := order[j - 1];
        order[j - 1] := order[j];
        order[j] := t;
      end;
  for j := 0 to count - 1 do
  begin
    i := order[j];
    c := project(px[i], py[i], pz[i]);
    writeln(format('  <circle cx="%s" cy="%s" r="15" fill="white" stroke="%s" stroke-width="3"/>',
      [num(c.u), num(c.v), layercolors[pz[i]]]));
    text(c.u, c.v, 14, 'black', 'middle', inttostr(i), true);
    if view = vw_top then
      text(c.u, c.v + 27, 12, layercolors[pz[i]], 'middle',
        format('(%d, %d, %d)', [px[i], py[i], pz[i]]), false);
  end;
end;

procedure drawlegend();
var
  z: integer;
  c: vecty;
begin
  if view = vw_3d then
    for z := -1 to 1 do
    begin
      c := project(1, -1, z);
      text(c.u + 28, c.v, 16, layercolors[z], 'start', format('z = %d', [z]), true);
    end
  else
    for z := -1 to 1 do
      text(originu + z * 110, height - 28, 16, layercolors[z], 'middle', format('z = %d', [z]), true);
end;

begin
  view := vw_3d;
  if (paramcount > 0) and (lowercase(paramstr(1)) = 'top') then
    view := vw_top
  else if (paramcount > 0) and (lowercase(paramstr(1)) <> '3d') then
  begin
    writeln(stderr, 'usage : drawcube [3d|top]');
    halt(1);
  end;
  build();
  if view = vw_top then
  begin
    unitsize := 90;
    width := 720;
    height := 780;
  end
  else
  begin
    unitsize := 150;
    width := 760;
    height := 820;
  end;
  originu := width / 2;
  originv := height / 2;
  if view = vw_top then
    originv := (height - 50) / 2;
  writeln('<?xml version="1.0" encoding="UTF-8"?>');
  writeln(format('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="DejaVu Sans, sans-serif">',
    [width, height, width, height]));
  writeln(format('  <rect width="%d" height="%d" fill="white"/>', [width, height]));
  drawgrid();
  drawlinks();
  drawcentres();
  drawpoints();
  drawlegend();
  writeln('</svg>');
end.
