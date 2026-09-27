program marques;

{$mode objfpc}{$h+}

uses
{$ifdef unix}
  cthreads,
{$endif}
  agg_2D,
  agg_basics,
  alphabitmap;

const
  selectionsize = 56;
  selectionradius = 26;
  destinationsize = 20;
  destinationradius = 8;

function green(const a: byte = 255): Color;
begin
  result.Construct(46, 184, 72, a);
end;

function darkgreen(const a: byte = 255): Color;
begin
  result.Construct(20, 110, 40, a);
end;

function lightgreen(const a: byte = 255): Color;
begin
  result.Construct(170, 240, 170, a);
end;

function red(const a: byte = 255): Color;
begin
  result.Construct(214, 48, 39, a);
end;

procedure drawring(const agg: agg2d_ptr; const asize: integer; const ahalo, aring: Color);
var
  c: double;
begin
  c := asize / 2;
  agg^.noFill();
  agg^.lineColor(ahalo);
  agg^.lineWidth(5);
  agg^.ellipse(c, c, selectionradius - 0.5, selectionradius - 0.5);
  agg^.lineColor(aring);
  agg^.lineWidth(3);
  agg^.ellipse(c, c, selectionradius, selectionradius);
end;

procedure drawselection(const agg: agg2d_ptr; const asize: integer);
begin
  drawring(agg, asize, green(70), green());
end;

procedure drawcapture(const agg: agg2d_ptr; const asize: integer);
begin
  drawring(agg, asize, red(70), red());
end;

procedure drawdestination(const agg: agg2d_ptr; const asize: integer);
var
  c: double;
begin
  c := asize / 2;
  agg^.noLine();
  agg^.fillColor(green(60));
  agg^.ellipse(c, c, destinationradius + 1.5, destinationradius + 1.5);
  agg^.fillRadialGradient(c - 2.5, c - 2.5, destinationradius * 1.6, lightgreen(), green());
  agg^.lineColor(darkgreen());
  agg^.lineWidth(1);
  agg^.ellipse(c, c, destinationradius - 0.5, destinationradius - 0.5);
end;

begin
  writealphaimage('selection.png', selectionsize, @drawselection);
  writealphaimage('destination.png', destinationsize, @drawdestination);
  writealphaimage('prise.png', selectionsize, @drawcapture);
end.
