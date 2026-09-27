unit piecedraw;

{$mode objfpc}{$h+}

interface

uses
  agg_2D,
  agg_basics;

type
  piecety = record
    light, dark, rim, groove: array[0..2] of byte;
  end;

const
  whitepiece: piecety = (
    light: (255, 255, 255); dark: (190, 190, 190); rim: (140, 140, 140); groove: (175, 175, 175));
  blackpiece: piecety = (
    light: (110, 110, 110); dark: (18, 18, 18); rim: (0, 0, 0); groove: (8, 8, 8));

function makecolor(const c: array of byte; const a: byte = 255): Color;
procedure drawpiece(const agg: agg2d_ptr; const acx, acy, aradius: double; const apiece: piecety; const agroove: boolean = true);

implementation

function makecolor(const c: array of byte; const a: byte = 255): Color;
begin
  result.Construct(c[0], c[1], c[2], a);
end;

procedure drawpiece(const agg: agg2d_ptr; const acx, acy, aradius: double; const apiece: piecety; const agroove: boolean);
var
  k: double;
begin
  k := aradius / 22;
  with apiece do
  begin
    agg^.fillRadialGradient(acx - 7 * k, acy - 8 * k, aradius * 1.5, makecolor(light), makecolor(dark));
    agg^.lineColor(makecolor(rim));
    agg^.lineWidth(1.2 * k);
    agg^.ellipse(acx, acy, aradius - 0.6 * k, aradius - 0.6 * k);
    if agroove then
    begin
      agg^.noFill();
      agg^.lineColor(makecolor(groove, 160));
      agg^.lineWidth(1.5 * k);
      agg^.ellipse(acx, acy, aradius * 0.62, aradius * 0.62);
    end;
  end;
end;

end.
