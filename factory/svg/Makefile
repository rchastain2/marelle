
PC := fpc
PFLAGS := -Mobjfpc -Sh

PROGRAM := drawcube
IMAGES := cube3d.svg cubetop.svg cube3d.png cubetop.png

all: $(IMAGES)

$(PROGRAM): $(PROGRAM).pas
	@$(PC) $(PFLAGS) $< > /dev/null

cube3d.svg: $(PROGRAM)
	@./$(PROGRAM) 3d > $@

cubetop.svg: $(PROGRAM)
	@./$(PROGRAM) top > $@

%.png: %.svg
	@rsvg-convert -o $@ $<

clean:
	@rm -fv *.bak *.bak? *.o *.ppu
	@rm -rfv units

distclean: clean
	@rm -fv $(PROGRAM) $(PROGRAM).exe $(IMAGES)

.PHONY: all clean distclean
.DELETE_ON_ERROR:
