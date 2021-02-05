#TEX = pdflatex -shell-escape -interaction=nonstopmode -file-line-error
TEX = xelatex -synctex=1 -shell-escape -interaction=nonstopmode -file-line-error
BIB = biber
THESISNAME = thesis
GTTNAME = guide-to-thesis
GLO = makeglossaries
TEXFILE = ${THESISNAME}.tex
PDFFILE = ${THESISNAME}.pdf
BCFFILE = ${THESISNAME}.bcf
GTTTEXFILE = ${GTTNAME}.tex
GTTPDFFILE = ${GTTNAME}.pdf
GTTBCFFILE = ${GTTNAME}.bcf
THESIS_OBJ = $(wildcard 00-settings/*.tex) $(wildcard 01-head/*.tex) $(wildcard 02-main/*.tex) $(wildcard 03-tail/*.tex)


.PHONY: thesis all clean clean_all

thesis : ${PDFFILE} $(THESIS_OBJ)

gtt : ${GTTPDFFILE}

all : ${PDFFILE} ${GTTPDFFILE}

${GTTPDFFILE} : ${GTTTEXFILE}
	@echo '+------------------------------------------------+'
	@echo '| Build ${GTTTEXFILE}"                              |'
	@echo '+------------------------------------------------+'
	${TEX} ${GTTNAME}; true
	${BIB} ${GTTNAME}; true
	${GLO} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
	@echo '+------------------------------------------------+'
	@echo '| Build ${GTTTEXFILE}                               |'
	@echo '+------------------------------------------------+'
	#@make clean

${PDFFILE} : ${TEXFILE} $(THESIS_OBJ)
	@echo '+------------------------------------------------+'
	@echo '| Build ${TEXFILE}"                              |'
	@echo '+------------------------------------------------+'
	${TEX} ${THESISNAME}; true
	${BIB} ${THESISNAME}; true
	${GLO} ${THESISNAME}; true
	${TEX} ${THESISNAME}; true
	${TEX} ${THESISNAME}; true
	${TEX} ${THESISNAME}; true
	@echo '+------------------------------------------------+'
	@echo '| Build ${TEXFILE}                               |'
	@echo '+------------------------------------------------+'
	#@make clean

clean :
	@rm *.aux || true
	@rm *.acn || true
	@rm *.acr || true
	@rm *.alg || true
	@rm *.bbl || true
	@rm *.bcf || true
	@rm *.blg || true
	@rm *.blx.aux || true
	@rm *.blx.bib || true
	@rm *.cb || true
	@rm *.cb2 || true
	@rm *.dvi || true
	@rm *.fdb_latexmk || true
	@rm *.fls || true
	@rm *.fmt || true
	@rm *.fot || true
	@rm *.lb || true
	@rm *.lof || true
	@rm *.loa || true
	@rm *.ist || true
	@rm *.log || true
	@rm *.lot || true
	@rm *.lol || true
	@rm *.out || true
	@rm *.toc || true
	@rm *.bak || true
	@rm *.pyg || true
	@rm *.backup || true
	@rm *.synctex || true
	@rm "*.synctex(busy)" || true
	@rm *.synctex.gz || true
	@rm "*.synctex.gz(busy)" || true
	@rm *.run.xml || true
	@rm *.glg || true
	@rm *.glo || true
	@rm *.gls || true
	@rm *.lot || true
	@rm *.xdy || true
	@rm *.xdv || true
	@rm 02-main/*.aux || true
	@rm 03-tail/*.aux || true
	@rm -rf _minted* || true
	@rm *.mtc* || true
	@rm *.maf || true
	@rm *.xwm || true
	@rm *.xml || true

clean-pdf :
	@rm ${PDFFILE} || true
	@rm ${GTTPDFFILE} || true

clean-all : clean clean-pdf