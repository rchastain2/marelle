unit main;

{$mode objfpc}{$h+}{$codepage utf8}

interface

uses
  msetypes,
  mseglob,
  mseguiglob,
  mseguiintf,
  mseapplication,
  msestat,
  msestatfile,
  msemenus,
  msegui,
  msegraphics,
  msegraphutils,
  mseevent,
  mseclasses,
  msewidgets,
  mseforms,
  msesimplewidgets,
  msebitmap,
  mseactions,
  game,
  computer,
  log;

const
  cellsize = 64;
  piecesize = 48;
  containerheight = 562;

type
  tmainfo = class(tmainform)
    board: tpaintbox;
    statuslb: tlabel;
    newgamebu: tbutton;
    menubar: tmainmenu;
    popupitemframe: tframecomp;
    popupitemframeactive: tframecomp;
    popupframe: tframecomp;
    baritemframe: tframecomp;
    baritemframeactive: tframecomp;
    separatorframe: tframecomp;
    barface: tfacecomp;
    activeface: tfacecomp;
    popupface: tfacecomp;
    newgameact: taction;
    playact: taction;
    autoplayact: taction;
    quitact: taction;
    mainstat: tstatfile;
    aboutact: taction;
    procedure createev(const sender: TObject);
    procedure destroyev(const sender: TObject);
    procedure paintev(const sender: twidget; const acanvas: tcanvas);
    procedure mouseev(const sender: twidget; var ainfo: mouseeventinfoty);
    procedure newgameev(const sender: TObject);
    procedure playev(const sender: TObject);
    procedure autoplayev(const sender: TObject);
    procedure quitev(const sender: TObject);
    procedure aboutev(const sender: TObject);
    procedure statafterreadev(const sender: TObject);
  private
    fplateau: tmaskedbitmap;
    fpieces: array[1..2] of tmaskedbitmap;
    fselection: tmaskedbitmap;
    fdestination: tmaskedbitmap;
    fcapture: tmaskedbitmap;
    fgame: tgame;
    fselected: integer;
    fdragging: boolean;
    fdragoffset: pointty;
    fdragpos: pointty;
    fcomputer: integer;
    procedure initgame();
    procedure updatestatus();
    procedure clickpoint(const aindex: integer);
    procedure checkcomputer();
    procedure setcomputer(const aplayer: integer);
    procedure updatecomputer();
    function playerlabel(const aplayer: integer): msestring;
    procedure playturn();
    function pointcenter(const aindex: integer): pointty;
    procedure paintcentered(const acanvas: tcanvas; const abitmap: tmaskedbitmap; const acenter: pointty);
    function pointatpos(const apos: pointty): integer;
  protected
    procedure doasyncevent(var atag: integer); override;
  end;

var
  mainfo: tmainfo;

implementation

uses
  sysutils,
  main_mfm,
  msefileutils,
  msesysintf,
  mseformatstr,
  mseformatpngread;

const
  coords: array[0..pointcount - 1, 0..1] of integer = (
    (1, 1), (4, 1), (7, 1),
    (2, 2), (4, 2), (6, 2),
    (3, 3), (4, 3), (5, 3),
    (1, 4), (2, 4), (3, 4),
    (5, 4), (6, 4), (7, 4),
    (3, 5), (4, 5), (5, 5),
    (2, 6), (4, 6), (6, 6),
    (1, 7), (4, 7), (7, 7)
  );

  playernames: array[1..2] of msestring = ('Blancs', 'Noirs');

procedure tmainfo.createev(const sender: TObject);
var
  dir: filenamety;
begin
  writelog('** Marelle, compilé le ' + {$i %date%} + ' avec FPC ' + {$i %fpcversion%}, true);
  dir := filedir(sys_getapplicationpath) + 'images/';
  fplateau := tmaskedbitmap.create(bmk_rgb);
  fplateau.loadfromfile(dir + 'plateau.png');
  fpieces[1] := tmaskedbitmap.create(bmk_rgb);
  fpieces[1].loadfromfile(dir + 'blanc.png');
  fpieces[2] := tmaskedbitmap.create(bmk_rgb);
  fpieces[2].loadfromfile(dir + 'noir.png');
  fselection := tmaskedbitmap.create(bmk_rgb);
  fselection.loadfromfile(dir + 'selection.png');
  fdestination := tmaskedbitmap.create(bmk_rgb);
  fdestination.loadfromfile(dir + 'destination.png');
  fcapture := tmaskedbitmap.create(bmk_rgb);
  fcapture.loadfromfile(dir + 'prise.png');
  icon.loadfromfile(dir + 'icone48.png');
  writelog(format('   Barre de menus : %d px, correction de la hauteur : %d px', [container.bounds_y, containerheight - container.bounds_cy]));
  bounds_cy := bounds_cy + containerheight - container.bounds_cy;
  fgame := tgame.create();
  fcomputer := 0;
  updatecomputer();
  initgame();
end;

procedure tmainfo.destroyev(const sender: TObject);
begin
  writelog('** Fin');
  fgame.free;
  fplateau.free;
  fpieces[1].free;
  fpieces[2].free;
  fselection.free;
  fdestination.free;
  fcapture.free;
end;

procedure tmainfo.initgame();
begin
  fgame.init();
  writelog('** Nouvelle partie');
  if fcomputer <> 0 then
    writelog('   L''ordinateur joue les ' + string(playernames[fcomputer]));
  fselected := -1;
  fdragging := false;
  updatestatus();
  board.invalidate();
  checkcomputer();
end;

procedure tmainfo.updatestatus();
var
  s: msestring;
  p: msestring;
begin
  p := playerlabel(fgame.player);
  case fgame.phase of
    ph_place:
      s := p + ' : placez un pion (' + inttostrmse(fgame.hand[fgame.player]) + ' en réserve)';
    ph_move:
      if fselected < 0 then
        s := p + ' : choisissez un pion à déplacer'
      else
        s := p + ' : choisissez la destination';
    ph_remove:
      s := p + ' : enlevez un pion adverse';
    ph_over:
      s := 'Partie terminée. Les ' + playerlabel(fgame.winner) + ' ont gagné !';
  end;
  statuslb.caption := s;
  playact.enabled := fgame.phase <> ph_over;
end;

function tmainfo.pointcenter(const aindex: integer): pointty;
begin
  result.x := coords[aindex, 0] * cellsize;
  result.y := coords[aindex, 1] * cellsize;
end;

procedure tmainfo.paintcentered(const acanvas: tcanvas; const abitmap: tmaskedbitmap; const acenter: pointty);
begin
  abitmap.paint(acanvas, mp(acenter.x - abitmap.width div 2, acenter.y - abitmap.height div 2));
end;

function tmainfo.pointatpos(const apos: pointty): integer;
var
  i: integer;
  c: pointty;
begin
  for i := 0 to pointcount - 1 do
  begin
    c := pointcenter(i);
    if (abs(apos.x - c.x) < piecesize div 2) and (abs(apos.y - c.y) < piecesize div 2) then
      exit(i);
  end;
  result := -1;
end;

procedure tmainfo.clickpoint(const aindex: integer);
begin
  writelog(format('<- Clic sur le point %d', [aindex]));
  case fgame.phase of
    ph_place:
      fgame.place(aindex);
    ph_move:
      if fgame.points[aindex] = fgame.player then
      begin
        fselected := aindex;
        writelog(format('   Sélection du pion %d', [aindex]));
      end
      else
      begin
        if fselected >= 0 then
          fgame.move(fselected, aindex);
        fselected := -1;
      end;
    ph_remove:
      fgame.remove(aindex);
  end;
  updatestatus();
  board.invalidate();
  checkcomputer();
end;

procedure tmainfo.setcomputer(const aplayer: integer);
begin
  if aplayer = fcomputer then
    exit;
  fcomputer := aplayer;
  if fcomputer = 0 then
    writelog('   L''ordinateur ne joue plus')
  else
    writelog('   L''ordinateur joue les ' + string(playernames[fcomputer]));
  updatestatus();
end;

procedure tmainfo.updatecomputer();
begin
  if autoplayact.checked then
    setcomputer(3 - fgame.player)
  else
    setcomputer(0);
end;

function tmainfo.playerlabel(const aplayer: integer): msestring;
begin
  result := playernames[aplayer];
  if fcomputer = aplayer then
    result := result + ' (ordinateur)'
  else if fcomputer <> 0 then
    result := result + ' (vous)';
end;

procedure tmainfo.checkcomputer();
begin
  if (fcomputer = fgame.player) and (fgame.phase <> ph_over) then
    asyncevent();
end;

procedure tmainfo.doasyncevent(var atag: integer);
begin
  inherited;
  if (fcomputer = fgame.player) and (fgame.phase <> ph_over) then
    playturn();
end;

procedure tmainfo.playturn();
var
  p: integer;
  a: computeractionty;
  done: boolean;
begin
  fselected := -1;
  fdragging := false;
  p := fgame.player;
  writelog('<- Tour de l''ordinateur (' + string(playernames[p]) + ')');
  done := true;
  while done and (fgame.player = p) and (fgame.phase <> ph_over) do
  begin
    a := chooseaction(fgame);
    if a.target < 0 then
    begin
      writelog('!! L''ordinateur ne trouve aucune action');
      break;
    end;
    case fgame.phase of
      ph_place:
        done := fgame.place(a.target);
      ph_move:
        done := fgame.move(a.source, a.target);
      ph_remove:
        done := fgame.remove(a.target);
    end;
  end;
  updatestatus();
  board.invalidate();
end;

procedure tmainfo.paintev(const sender: twidget; const acanvas: tcanvas);
var
  i: integer;
  c: pointty;
begin
  fplateau.paint(acanvas, nullpoint);
  for i := 0 to pointcount - 1 do
  begin
    c := pointcenter(i);
    if (fgame.points[i] <> 0) and not (fdragging and (i = fselected)) then
      paintcentered(acanvas, fpieces[fgame.points[i]], c);
    if (fgame.phase = ph_remove) and fgame.maytake(i) then
      paintcentered(acanvas, fcapture, c)
    else if (fgame.phase = ph_move) and (fselected >= 0) and fgame.maymove(fselected, i) then
      paintcentered(acanvas, fdestination, c);
  end;
  if (fgame.phase = ph_move) and (fselected >= 0) then
    paintcentered(acanvas, fselection, pointcenter(fselected));
  if fdragging then
    paintcentered(acanvas, fpieces[fgame.player], subpoint(fdragpos, fdragoffset));
end;

procedure tmainfo.mouseev(const sender: twidget; var ainfo: mouseeventinfoty);
var
  i: integer;
begin
  if (fgame.phase = ph_over) or (fcomputer = fgame.player) then
    exit;
  case ainfo.eventkind of
    ek_buttonpress:
      if ainfo.button = mb_left then
      begin
        i := pointatpos(ainfo.pos);
        if (fgame.phase = ph_move) and (i >= 0) and (fgame.points[i] = fgame.player) then
        begin
          fselected := i;
          fdragging := true;
          fdragoffset := subpoint(ainfo.pos, pointcenter(i));
          fdragpos := ainfo.pos;
          updatestatus();
          board.invalidate();
        end;
      end;
    ek_mousemove:
      if fdragging then
      begin
        fdragpos := ainfo.pos;
        board.invalidate();
      end;
    ek_buttonrelease:
      if ainfo.button = mb_left then
      begin
        i := pointatpos(ainfo.pos);
        if fdragging then
        begin
          fdragging := false;
          if (i >= 0) and (i <> fselected) then
            clickpoint(i)
          else
            board.invalidate();
        end else if i >= 0 then
          clickpoint(i)
        else if fselected >= 0 then
        begin
          fselected := -1;
          updatestatus();
          board.invalidate();
        end;
      end;
  end;
end;

procedure tmainfo.newgameev(const sender: TObject);
begin
  initgame();
end;

procedure tmainfo.playev(const sender: TObject);
begin
  writelog('** Commande Jouer');
  if fgame.phase = ph_over then
    exit;
  if autoplayact.checked then
  begin
    setcomputer(fgame.player);
    checkcomputer();
  end
  else
    playturn();
end;

procedure tmainfo.autoplayev(const sender: TObject);
begin
  if autoplayact.checked then
    writelog('** Réponse automatique activée')
  else
    writelog('** Réponse automatique désactivée');
  updatecomputer();
  checkcomputer();
end;


procedure tmainfo.quitev(const sender: TObject);
begin
  writelog('** Commande Quitter');
  close();
end;


procedure tmainfo.aboutev(const sender: TObject);
begin
  writelog('** Commande À propos');
  showmessage(
    'Marelle' + lineend + lineend +
    'Jeu du moulin (mérelles) pour deux joueurs, ou contre l''ordinateur.' + lineend + lineend +
    'Logique du jeu reprise de Mérelles, de Paul-Maxime.' + lineend +
    'Règle de prise des pions en moulin reprise de Morris, de Dirk Farin.' + lineend +
    'Images dessinées avec AGGPas ; texture de bois de Wood Texture Tiles.' + lineend + lineend +
    'Compilé le ' + {$i %date%} + ' avec FPC ' + {$i %fpcversion%} + ' et MSEgui ' + mseguiversiontext + '.',
    'À propos');
end;


procedure tmainfo.statafterreadev(const sender: TObject);
begin
  if fgame = nil then
    exit;
  if autoplayact.checked then
    writelog('   Réglages relus : réponse automatique activée')
  else
    writelog('   Réglages relus : réponse automatique désactivée');
  updatecomputer();
  checkcomputer();
end;

end.
