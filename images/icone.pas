program icone;

{$mode objfpc}{$h+}

uses
{$ifdef unix}
  cthreads,
{$endif}
  sysutils,
  math,
  agg_2D,
  agg_basics,
  alphabitmap,
  piecedraw;

const
  sizes: array[0..4] of integer = (16, 32, 48, 64, 128);
  woodlight: array[0..2] of byte = (224, 192, 142);
  wooddark: array[0..2] of byte = (188, 146, 92);
  woodrim: array[0..2] of byte = (140, 100, 55);
  gray = 51;

var
  linewidth: integer;

function snap(const av: double): double;
begin
  if odd(linewidth) then
    result := floor(av) + 0.5
  else
    result := round(av);
end;

procedure drawbackground(const agg: agg2d_ptr; const n, margin: double);
begin
  agg^.fillLinearGradient(0, 0, 0, n, makecolor(woodlight), makecolor(wooddark));
  agg^.lineColor(makecolor(woodrim));
  agg^.lineWidth(n / 64);
  agg^.roundedRect(margin, margin, n - margin, n - margin, n * 0.18);
end;

procedure drawboard(const agg: agg2d_ptr; const n, margin: double);
var
  a, m, b, r, dot, stop: double;
begin
  linewidth := max(1, round(n / 40));
  a := snap(n * 0.22);
  m := snap(n * 0.5);
  b := snap(n * 0.78);
  r := n * 0.095;
  dot := max(1.2, n * 0.03);
  stop := snap(n * 0.1);
  agg^.noFill();
  agg^.lineColor(gray, gray, gray);
  agg^.lineWidth(linewidth);
  agg^.rectangle(a, a, b, b);
  agg^.line(m, a, m, stop);
  agg^.line(m, b, m, n - stop);
  agg^.line(a, m, stop, m);
  agg^.line(b, m, n - stop, m);
  agg^.noLine();
  agg^.fillColor(gray, gray, gray);
  agg^.ellipse(m, a, dot, dot);
  agg^.ellipse(m, b, dot, dot);
  agg^.ellipse(b, a, dot, dot);
  agg^.ellipse(b, b, dot, dot);
  drawpiece(agg, a, a, r, whitepiece, n >= 64);
  drawpiece(agg, a, m, r, whitepiece, n >= 64);
  drawpiece(agg, a, b, r, whitepiece, n >= 64);
  drawpiece(agg, b, m, r, blackpiece, n >= 64);
end;

procedure draw(const agg: agg2d_ptr; const asize: integer);
var
  n, margin: double;
begin
  n := asize;
  margin := n / 32;
  drawbackground(agg, n, margin);
  if asize <= 16 then
    drawpiece(agg, n / 2, n / 2, n * 0.3, whitepiece, false)
  else
    drawboard(agg, n, margin);
end;

var
  i: integer;

begin
  for i := low(sizes) to high(sizes) do
    writealphaimage(format('icone%d.png', [sizes[i]]), sizes[i], @draw);
end.
