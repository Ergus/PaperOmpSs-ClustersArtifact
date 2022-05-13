# Copyright (C) 2022  Jimmy Aguilar Mena

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

SHELL:=bash

all: Overview.pdf

%.pdf: %.tex
	latexmk -f -pdf -pdflatex="pdflatex -interaction=nonstopmode -file-line-error -synctex=1" -use-make $<

artifact.zip: Overview.pdf artifact.sh process_dim.py
	zip $@ $^

.PHONY: clean show

clean:
	latexmk -CA
	rm -rf *.{zip,ps,pdf,log,aux,out,dvi,bbl,blg,ist,glsdefs,gls,glo,glg,xdy,synctex.gz,toc,bcf,xml,nav,snm,fls,fdb_latexmk} auto _region_.tex

show: main.pdf
	xdg-open $< &

