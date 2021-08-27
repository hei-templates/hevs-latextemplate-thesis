.PHONY: thesis all clean clean_all

###########################################################################
# GLOBALS                                                                 #
###########################################################################
PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PYTHON_INTERPRETER = python
CONDA_ENV_WIN_FILE = condaenv-win.yml
CONDA_ENV_LINUX_FILE = condaenv-linux.yml
CONDA_ENV_NAME = latex-env

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

ifeq (,$(shell where conda))
HAS_CONDA=False
else
HAS_CONDA=True
SEARCH_ENV=$(shell conda.bat info --envs | grep $(CONDA_ENV_NAME))
FOUND_ENV_NAME = $(word 1, $(notdir $(SEARCH_ENV)))
# check if conda environment is active
ifneq ($(CONDA_DEFAULT_ENV),$(FOUND_ENV_NAME))
	CONDA_ACTIVATE := source $$(conda.bat info --base)/etc/profile.d/conda.sh ; conda activate $(CONDA_ENV_NAME)
else
    CONDA_ACTIVATE := true
endif
endif

###########################################################################
# COMMANDS                                                                #
###########################################################################

conda-create-win: ## Install conda environment for windows
	@conda env create -f $(CONDA_ENV_WIN_FILE)
	@echo ">>> Conda environment '$(CONDA_ENV_NAME)' create."

conda-export-win: ## export conda environment for windows
	@conda env export > $(CONDA_ENV_WIN_FILE)
	@echo ">>> Conda environment '$(CONDA_ENV_NAME)' exported."

conda-create-linux: ## Install conda environment for linux
	@conda env create -f $(CONDA_ENV_LINUX_FILE)
	@echo ">>> Conda environment '$(CONDA_ENV_NAME)' create."

conda-export-linux: ## export conda environment for linux
	@conda env export > $(CONDA_ENV_LINUX_FILE)
	@echo ">>> Conda environment '$(CONDA_ENV_NAME)' exported."

thesis: ${PDFFILE} $(THESIS_OBJ) ## Generate thesis

gtt: ${GTTPDFFILE} ## Generate guide-to-thesis

all: ${PDFFILE} ${GTTPDFFILE} ## Generate all tex files

${GTTPDFFILE}: ${GTTTEXFILE}
	@$(CONDA_ACTIVATE)
	@echo '+------------------------------------------------+'
	@echo '| Build ${GTTTEXFILE}                            |'
	@echo '+------------------------------------------------+'
	${TEX} ${GTTNAME}; true
	${BIB} ${GTTNAME}; true
	${GLO} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
	@echo '+------------------------------------------------+'
	@echo '| Build ${GTTTEXFILE}                            |'
	@echo '+------------------------------------------------+'
	@make clean

${PDFFILE}: ${TEXFILE} $(THESIS_OBJ)
	@$(CONDA_ACTIVATE)
	@echo '+------------------------------------------------+'
	@echo '| Build ${TEXFILE}                               |'
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
	@make clean

clean: ## Clean all intermediate files
	@echo '+------------------------------------------------+'
	@echo '| Clean                                          |'
	@echo '+------------------------------------------------+'
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

clean-pdf: ## Clean all pdf files
	@echo '+------------------------------------------------+'
	@echo '| Clean ${PDFFILE} & ${GTTPDFFILE}               |'
	@echo '+------------------------------------------------+'
	@rm ${PDFFILE} || true
	@rm ${GTTPDFFILE} || true

clean-all: clean clean-pdf ## Clean all intermediate files including pdfs

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help