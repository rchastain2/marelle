unit alphabitmap;

{$mode objfpc}{$h+}

interface

uses
  msetypes,
  msegraphutils,
  msegraphics,
  msebitmap,
  mseformatpngwrite,
  agg_2D;

type
  drawproc = procedure(const agg: agg2d_ptr; const asize: integer);

procedure writealphaimage(const afilename: string; const asize: integer; const adraw: drawproc);

implementation

procedure extractalpha(const abitmap: tmaskedbitmap);
var
  x, y: integer;
  p: prgbtriplety;
  m: pbyte;
begin
  for y := 0 to abitmap.height - 1 do
  begin
    p := abitmap.scanline[y];
    m := abitmap.mask.scanline[y];
    for x := 0 to abitmap.width - 1 do
    begin
      m^ := p^.res;
      if p^.res > 0 then
      begin
        p^.red := p^.red * 255 div p^.res;
        p^.green := p^.green * 255 div p^.res;
        p^.blue := p^.blue * 255 div p^.res;
      end;
      p^.res := 0;
      inc(p);
      inc(m);
    end;
  end;
end;

procedure writealphaimage(const afilename: string; const asize: integer; const adraw: drawproc);
var
  bitmap: tmaskedbitmap;
  agg: agg2d_ptr;
begin
  bitmap := tmaskedbitmap.create(bmk_rgb);
  try
    bitmap.graymask := true;
    bitmap.masked := true;
    bitmap.size := makesize(asize, asize);
    new(agg, construct);
    agg^.attach(pbyte(bitmap.scanline[0]), bitmap.width, bitmap.height, bitmap.scanlinestep);
    agg^.clearAll(0, 0, 0, 0);
    adraw(agg, asize);
    dispose(agg, destruct);
    extractalpha(bitmap);
    bitmap.writetofile(msestring(afilename), 'png', []);
    writeln('Written: ', afilename);
  finally
    bitmap.free;
  end;
end;

end.
