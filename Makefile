.PHONY: info conda-create conda-export clean view help thesis all clean clean_all gtt thesis all

###########################################################################
# Detect OS                                                               #
###########################################################################
ifeq ($(OS),Windows_NT)
detected_OS := Windows
else
detected_OS := $(shell uname)
endif

###########################################################################
# GLOBALS                                                                 #
###########################################################################
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST)))) # $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PYTHON_INTERPRETER = python
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

###########################################################################
# OS Specifics                                                            #
###########################################################################
ifeq ($(detected_OS),Windows)
	PDFVIEWER = 'start "" /max'
	CONDA_ENV_FILE = condaenv-win.yml
ifeq (,$(shell where conda))
	HAS_CONDA = False
else
	HAS_CONDA = True
	SEARCH_ENV = $(shell conda.bat info --envs | findstr $(CONDA_ENV_NAME))
	FOUND_ENV_NAME = $(word 1, $(notdir $(SEARCH_ENV)))
	ENV_DIR = $(shell conda.bat info --base)
	MY_ENV_DIR = $(ENV_DIR)/envs/$(CONDA_ENV_NAME)
	# check if conda environment is active
ifneq ($(CONDA_DEFAULT_ENV),$(CONDA_ENV_NAME))
	CONDA_ACTIVATE := call conda activate $(CONDA_ENV_NAME)
endif
endif
endif

ifeq ($(detected_OS),Darwin)
	PDFVIEWER = open
	CONDA_ENV_FILE = condaenv-mac-arm64.yml
ifeq (,$(shell which conda))
	HAS_CONDA = False
else
	HAS_CONDA = True
	ENV_DIR = $(shell conda info --base)
	MY_ENV_DIR = $(ENV_DIR)/envs/$(CONDA_ENV_NAME)
	CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate $(CONDA_ENV_NAME)
endif
endif

ifeq ($(detected_OS),Linux)
	#SHELL = /bin/zsh
	SHELL = /bin/bash
	PDFVIEWER = xdg-open
	CONDA_ENV_FILE = condaenv-linux.yml
ifeq (,$(shell which conda))
	HAS_CONDA = False
else
	HAS_CONDA = True
	ENV_DIR = $(shell conda info --base)
	MY_ENV_DIR = $(ENV_DIR)/envs/$(CONDA_ENV_NAME)
	CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate $(CONDA_ENV_NAME)
endif
endif

###########################################################################
# COMMANDS                                                                #
###########################################################################
.ONESHELL:

info: ## Information about the environemnt
	@echo "Environment Informations"
	@echo "  * Detected OS: $(detected_OS)"
	@echo "  * Pdfviewer: $(PDFVIEWER)"
	@echo "  * Conda found: $(HAS_CONDA)"
	@echo "  * Conda envfile: $(CONDA_ENV_FILE)"
	@echo "  * Conda dir: $(ENV_DIR)"
	@echo "  * Conda envdir: $(MY_ENV_DIR)"

conda-create: ## Install conda environment
ifeq (True,$(HAS_CONDA))
ifneq ("$(wildcard $(MY_ENV_DIR))","") # check if the directory is there
	@echo ">>> Found $(CONDA_ENV_NAME) environment in $(MY_ENV_DIR). Skipping installation..."
else
	@echo ">>> Detected conda, but $(CONDA_ENV_NAME) is missing in $(ENV_DIR). Installing ..."
	@conda env create -f $(CONDA_ENV_FILE) -n $(CONDA_ENV_NAME)
endif
else
	@echo ">>> Install conda first."
	exit
endif

conda-export: ## export conda environment
	@conda env export > $(CONDA_ENV_FILE)
	@echo ">>> Conda environment '$(CONDA_ENV_NAME)' exported."

thesis: ${PDFFILE} $(THESIS_OBJ) ## Generate thesis

gtt: ${GTTPDFFILE} ## Generate guide-to-thesis

all: ${PDFFILE} ${GTTPDFFILE} ## Generate all pdf files

${GTTPDFFILE}: ${GTTTEXFILE}
	@$(CONDA_ACTIVATE)
	@echo "+------------------------------------------------+"
	@echo "| Build ${GTTTEXFILE}                            |"
	@echo "+------------------------------------------------+"
ifeq ($(detected_OS),Windows)
	${TEX} ${GTTNAME}
	${BIB} ${GTTNAME}
	${GLO} ${GTTNAME}
	${TEX} ${GTTNAME}
	${TEX} ${GTTNAME}
	${TEX} ${GTTNAME}
else
	${TEX} ${GTTNAME}; true
	${BIB} ${GTTNAME}; true
	${GLO} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
	${TEX} ${GTTNAME}; true
endif
	@make clean

${PDFFILE}: ${TEXFILE} $(THESIS_OBJ)
	@$(CONDA_ACTIVATE)
	@echo "+------------------------------------------------+"
	@echo "| Build ${TEXFILE}                               |"
	@echo "+------------------------------------------------+"
ifeq ($(detected_OS),Windows)
	${TEX} ${THESISNAME}
	${BIB} ${THESISNAME}
	${GLO} ${THESISNAME}
	${TEX} ${THESISNAME}
	${TEX} ${THESISNAME}
	${TEX} ${THESISNAME}
else
	${TEX} ${THESISNAME}; true
	${BIB} ${THESISNAME}; true
	${GLO} ${THESISNAME}; true
	${TEX} ${THESISNAME}; true
	${TEX} ${THESISNAME}; true
	${TEX} ${THESISNAME}; true
endif
	@make clean

clean: ## Clean all intermediate files
	@echo "+------------------------------------------------+"
	@echo "| Clean                                          |"
	@echo "+------------------------------------------------+"
ifeq ($(detected_OS),Windows)
	@del /q /s *.aux 2>nul
	@del /q /s *.acn 2>nul
	@del /q /s *.acr 2>nul
	@del /q /s *.alg 2>nul
	@del /q /s *.bbl 2>nul
	@del /q /s *.bcf 2>nul
	@del /q /s *.blg 2>nul
	@del /q /s *.blx.aux 2>nul
	@del /q /s *.blx.bib 2>nul
	@del /q /s *.cb 2>nul
	@del /q /s *.cb2 2>nul
	@del /q /s *.dvi 2>nul
	@del /q /s *.fdb_latexmk 2>nul
	@del /q /s *.fls 2>nul
	@del /q /s *.fmt 2>nul
	@del /q /s *.fot 2>nul
	@del /q /s *.lb 2>nul
	@del /q /s *.lof 2>nul
	@del /q /s *.loa 2>nul
	@del /q /s *.ist 2>nul
	@del /q /s *.log 2>nul
	@del /q /s *.lot 2>nul
	@del /q /s *.lol 2>nul
	@del /q /s *.out 2>nul
	@del /q /s *.toc 2>nul
	@del /q /s *.bak 2>nul
	@del /q /s *.pyg 2>nul
	@del /q /s *.backup 2>nul
	@del /q /s *.synctex 2>nul
	@del /q /s "*.synctex(busy)" 2>nul
	@del /q /s *.synctex.gz 2>nul
	@del /q /s "*.synctex.gz(busy)" 2>nul
	@del /q /s *.run.xml 2>nul
	@del /q /s *.glg 2>nul
	@del /q /s *.glo 2>nul
	@del /q /s *.gls 2>nul
	@del /q /s *.lot 2>nul
	@del /q /s *.xdy 2>nul
	@del /q /s *.xdv 2>nul
	@del /q /s 02-main\*.aux 2>nul
	@del /q /s 03-tail\*.aux 2>nul
	@del /q /s -rf _minted* 2>nul
	@del /q /s *.mtc* 2>nul
	@del /q /s *.maf 2>nul
	@del /q /s *.xwm 2>nul
	@del /q /s *.xml 2>nul
else
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
endif

clean-pdf: ## Clean all pdf files
	@echo "+------------------------------------------------+"
	@echo "| Clean ${PDFFILE} & ${GTTPDFFILE}               |"
	@echo "+------------------------------------------------+"
ifeq ($(detected_OS),Windows)
	@del /q /s ${PDFFILE} 2>nul
	@del /q /s ${GTTPDFFILE} 2>nul
else
	@rm ${PDFFILE} || true
	@rm ${GTTPDFFILE} || true
endif

clean-all: clean clean-pdf ## Clean all intermediate files including pdfs

help: ## Show this help
ifeq ($(detected_OS),Windows)
	@type $(MAKEFILE_LIST) | findstr /R /C:"^[a-zA-Z_-]..*:.*## .*$" | sort > t.log
else
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
endif

.DEFAULT_GOAL := help
