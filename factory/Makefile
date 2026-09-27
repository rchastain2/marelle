
PC := fpc
PFLAGS := -Mobjfpc -Sh

PROGRAM := factory

$(PROGRAM): $(PROGRAM).pas
	@$(PC) $(PFLAGS) $<

tables.inc: $(PROGRAM)
	@./$(PROGRAM) > $@

images:
	@$(MAKE) -s -C svg
	@$(MAKE) -s -C tikz

clean:
	@rm -fv *.bak *.bak? *.log *.o *.ppu
	@$(MAKE) -s -C svg clean
	@$(MAKE) -s -C tikz clean

distclean: clean
	@rm -fv $(PROGRAM) $(PROGRAM).exe tables.inc
	@$(MAKE) -s -C svg distclean
	@$(MAKE) -s -C tikz distclean

.PHONY: images clean distclean
.DELETE_ON_ERROR:
