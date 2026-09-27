program plateau;

{$mode objfpc}{$h+}

uses
{$ifdef unix}
  cthreads,
{$endif}
  msetypes,
  msegraphutils,
  msegraphics,
  msebitmap,
  mseformatpngread,
  mseformatpngwrite,
  agg_2D,
  agg_basics;

const
  size = 512;
  texture = 'wood2.png';
  filename = 'plateau.png';
  linewidth = 0.003;
  dotradius = 0.007;
  gray = 51;

function isvalid(const ax, ay: integer): boolean;
var
  d: integer;
begin
  d := abs(ax - 4);
  if abs(ay - 4) > d then
    d := abs(ay - 4);
  result := (d > 0) and (abs(ax - 4) mod d = 0) and (abs(ay - 4) mod d = 0);
end;

procedure draw(const abitmap: tmaskedbitmap);
var
  agg: agg2d_ptr;
  u: double;
  i, x, y: integer;
begin
  u := size / 8;
  new(agg, construct);
  agg^.attach(pbyte(abitmap.scanline[0]), abitmap.width, abitmap.height, abitmap.scanlinestep);
  agg^.noFill();
  agg^.lineColor(gray, gray, gray);
  agg^.lineWidth(linewidth * size);
  for i := 1 to 3 do
    agg^.rectangle(i * u, i * u, (8 - i) * u, (8 - i) * u);
  agg^.line(1 * u, 4 * u, 3 * u, 4 * u);
  agg^.line(4 * u, 1 * u, 4 * u, 3 * u);
  agg^.line(5 * u, 4 * u, 7 * u, 4 * u);
  agg^.line(4 * u, 5 * u, 4 * u, 7 * u);
  agg^.noLine();
  agg^.fillColor(gray, gray, gray);
  for y := 1 to 7 do
    for x := 1 to 7 do
      if isvalid(x, y) then
        agg^.ellipse(x * u, y * u, dotradius * size, dotradius * size);
  dispose(agg, destruct);
end;

var
  bitmap: tmaskedbitmap;

begin
  bitmap := tmaskedbitmap.create(bmk_rgb);
  try
    bitmap.loadfromfile(msestring(texture));
    bitmap.masked := false;
    if (bitmap.width <> size) or (bitmap.height <> size) then
    begin
      writeln(stderr, 'Unexpected texture size: ', bitmap.width, 'x', bitmap.height);
      halt(1);
    end;
    draw(bitmap);
    bitmap.writetofile(msestring(filename), 'png', []);
    writeln('Written: ', filename);
  finally
    bitmap.free;
  end;
end.
