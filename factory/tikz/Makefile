
#LATEX := pdflatex
LATEX := lualatex

DOCUMENTS := cube3d cubetop

all: $(addsuffix .pdf,$(DOCUMENTS)) $(addsuffix .png,$(DOCUMENTS))

%.pdf: %.tex
	@$(LATEX) -interaction=batchmode $< > /dev/null

%.png: %.pdf
	@pdftoppm -png -r 150 -singlefile $< $*

clean:
	@rm -fv *.aux *.log

distclean: clean
	@rm -fv $(addsuffix .pdf,$(DOCUMENTS)) $(addsuffix .png,$(DOCUMENTS))

.PHONY: all clean distclean
.DELETE_ON_ERROR:
