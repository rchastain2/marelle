
ifndef MSEDIR
MSEDIR := mseide-msegui/
# git clone https://github.com/mse-org/mseide-msegui.git
endif
MSELIBDIR := $(MSEDIR)lib/common/

ifndef FPGUI
FPGUI := fpgui
# git clone https://github.com/graemeg/fpgui.git fpgui
endif
AGGPAS := $(FPGUI)/framework/src/main/pascal/corelib/render/software

ifeq ($(OS),Windows_NT)
OS := windows
else
OS := linux
endif

PC = fpc

PFLAGS := -Mobjfpc -Sh
PFLAGS += -Fu$(MSELIBDIR)*
PFLAGS += -Fu$(MSELIBDIR)kernel/$(OS)
PFLAGS += -Fi$(AGGPAS)
PFLAGS += -Fu$(AGGPAS)

PROGRAMS := pions plateau marques icone
TOOLS := preview
ICONS := icone16.png icone32.png icone48.png icone64.png icone128.png
IMAGES := blanc.png noir.png plateau.png selection.png destination.png prise.png $(ICONS) marelle.ico

all: $(IMAGES)

$(TOOLS): %: %.pas
	@$(PC) $(PFLAGS) $< > /dev/null

preview.png: preview $(IMAGES)
	@./preview

$(PROGRAMS): %: %.pas alphabitmap.pas piecedraw.pas
	@$(PC) $(PFLAGS) $< > /dev/null

blanc.png noir.png &: pions
	@./pions

plateau.png: plateau wood2.png
	@./plateau

selection.png destination.png prise.png &: marques
	@./marques

$(ICONS) &: icone
	@./icone

marelle.ico: $(ICONS)
	@magick $(ICONS) $@

clean:
	@rm -fv *.bak *.bak? *.o *.ppu
	@rm -rfv units

distclean: clean
	@rm -fv $(PROGRAMS) $(addsuffix .exe,$(PROGRAMS)) $(IMAGES)
	@rm -fv $(TOOLS) $(addsuffix .exe,$(TOOLS)) preview.png

.PHONY: all clean distclean
