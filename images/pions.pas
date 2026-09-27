program pions;

{$mode objfpc}{$h+}

uses
{$ifdef unix}
  cthreads,
{$endif}
  agg_2D,
  agg_basics,
  alphabitmap,
  piecedraw;

const
  size = 48;
  radius = 22;
  filenames: array[0..1] of string = ('blanc.png', 'noir.png');

var
  current: integer;

procedure draw(const agg: agg2d_ptr; const asize: integer);
begin
  if current = 0 then
    drawpiece(agg, asize / 2, asize / 2, radius, whitepiece)
  else
    drawpiece(agg, asize / 2, asize / 2, radius, blackpiece);
end;

begin
  for current := low(filenames) to high(filenames) do
    writealphaimage(filenames[current], size, @draw);
end.
