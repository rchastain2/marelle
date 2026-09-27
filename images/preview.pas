program preview;

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
  mseformatpngwrite;

const
  cellsize = 64;
  filename = 'preview.png';
  position = '.n..b.....b..b...n..b..n';
  selected = 4;
  destinations: array[0..2] of integer = (3, 5, 7);
  captures: array[0..1] of integer = (17, 23);

var
  gridx, gridy: array[0..23] of integer;

procedure buildgrid();
var
  x, y, d, n: integer;
begin
  n := 0;
  for y := 1 to 7 do
    for x := 1 to 7 do
    begin
      d := abs(x - 4);
      if abs(y - 4) > d then
        d := abs(y - 4);
      if (d > 0) and (abs(x - 4) mod d = 0) and (abs(y - 4) mod d = 0) then
      begin
        gridx[n] := x * cellsize;
        gridy[n] := y * cellsize;
        inc(n);
      end;
    end;
end;

function loadimage(const afilename: string): tmaskedbitmap;
begin
  result := tmaskedbitmap.create(bmk_rgb);
  result.loadfromfile(msestring(afilename));
  if not result.masked or (result.mask.kind <> bmk_gray) then
  begin
    writeln(stderr, 'No alpha channel: ', afilename);
    halt(1);
  end;
end;

procedure blend(const adest, asource: tmaskedbitmap; const acenter: integer);
var
  x, y, dx, dy, left, top: integer;
  s, d: prgbtriplety;
  m: pbyte;
  a: integer;
begin
  left := gridx[acenter] - asource.width div 2;
  top := gridy[acenter] - asource.height div 2;
  for y := 0 to asource.height - 1 do
  begin
    dy := top + y;
    if (dy < 0) or (dy >= adest.height) then
      continue;
    s := asource.scanline[y];
    m := asource.mask.scanline[y];
    d := adest.scanline[dy];
    for x := 0 to asource.width - 1 do
    begin
      dx := left + x;
      a := m[x];
      if (a > 0) and (dx >= 0) and (dx < adest.width) then
        with d[dx] do
        begin
          red := (s[x].red * a + red * (255 - a)) div 255;
          green := (s[x].green * a + green * (255 - a)) div 255;
          blue := (s[x].blue * a + blue * (255 - a)) div 255;
        end;
    end;
  end;
end;

var
  board, white, black, selection, destination, capture: tmaskedbitmap;
  i: integer;

begin
  buildgrid();
  board := tmaskedbitmap.create(bmk_rgb);
  white := loadimage('blanc.png');
  black := loadimage('noir.png');
  selection := loadimage('selection.png');
  destination := loadimage('destination.png');
  capture := loadimage('prise.png');
  try
    board.loadfromfile(msestring('plateau.png'));
    board.masked := false;
    for i := 0 to 23 do
      case position[i + 1] of
        'b': blend(board, white, i);
        'n': blend(board, black, i);
      end;
    blend(board, selection, selected);
    for i in destinations do
      blend(board, destination, i);
    for i in captures do
      blend(board, capture, i);
    board.writetofile(msestring(filename), 'png', []);
    writeln('Written: ', filename);
  finally
    board.free;
    white.free;
    black.free;
    selection.free;
    destination.free;
    capture.free;
  end;
end.
