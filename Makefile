# Lab Manual and Set-up Instructions

default: 
	@echo "make -n ... to display commands with running"
	@echo "make -s ... to not display commands when running them"
	@echo "Choices: setup-h, setup-l, 121-h, 121-l, images, list (prints copy-paste select image creation), counterr, toperr, typeerr, allerr"
	@echo "make all will make all html, all latex, and images"
	@echo -e "Suggested process: \nmake 121-p\nmake labdpdf (fix with PDFsam as instructed)\nmake checksize (then if different, continue)\nmake fixsize\nREPEAT ONCE"

git: 
	git diff-index --stat master

view: 
	/c/Program\ Files/Mozilla\ Firefox/firefox.exe TMC-lab-setup.html fall-lab-manual.html > /dev/null &

mathbook-setup-latex.xsl: 
	git diff-index --name-only master | grep mathbook-setup-latex.xsl && git diff-index --stat master 

mathbook-setup-html.xsl: 
	git diff-index --name-only master | grep mathbook-setup-html.xsl && git diff-index --stat master

mathbook-lab-latex.xsl: 
	git diff-index --name-only master | grep mathbook-lab-latex.xsl && git diff-index --stat master 

mathbook-lab-html.xsl: 
	git diff-index --name-only master | grep mathbook-lab-html.xsl && git diff-index --stat master

Lab-setup-121.xml:
	git diff-index --name-only master | grep Lab-setup-121.xml && git diff-index --stat master

121-Lab-Manual.xml:
	git diff-index --name-only master | grep 121-Lab-Manual.xml && git diff-index --stat master


${BEE}/user/mathbook-setup-latex.xsl: mathbook-setup-latex.xsl
	cp mathbook-setup-latex.xsl ${BEE}/user/

${BEE}/user/mathbook-setup-html.xsl: mathbook-setup-html.xsl
	cp mathbook-setup-html.xsl ${BEE}/user/

${BEE}/user/mathbook-lab-latex.xsl: mathbook-lab-latex.xsl
	cp mathbook-lab-latex.xsl ${BEE}/user/

${BEE}/user/mathbook-lab-html.xsl: mathbook-lab-html.xsl
	cp mathbook-lab-html.xsl ${BEE}/user/

setup-h: ${BEE}/user/mathbook-setup-html.xsl Lab-setup-121.xml 
	xsltproc ${BEE}/user/mathbook-setup-html.xsl Lab-setup-121.xml

setup-l: ${BEE}/user/mathbook-setup-latex.xsl Lab-setup-121.xml 
	xsltproc ${BEE}/user/mathbook-setup-latex.xsl Lab-setup-121.xml

setup-p: setup-l
	pdflatex TMC-lab-setup.tex && pdflatex TMC-lab-setup.tex || pdflatex TMC-lab-setup.tex

setup: setup-h setup-p


121-h: ${BEE}/user/mathbook-lab-html.xsl 121-Lab-Manual.xml
	xsltproc ${BEE}/user/mathbook-lab-html.xsl 121-Lab-Manual.xml
	@echo ""

121-l: ${BEE}/user/mathbook-lab-latex.xsl 121-Lab-Manual.xml
	xsltproc ${BEE}/user/mathbook-lab-latex.xsl 121-Lab-Manual.xml
	sed -i.sedfix -f 121-Lab-Manual.sed fall-lab-manual.tex

fall-lab-manual.tex: 121-l

121-p: fall-lab-manual.tex
	pdflatex fall-lab-manual.tex && pdflatex fall-lab-manual.tex || pdflatex fall-lab-manual.tex
	@echo "\\\n\\\nYou should probably run [make labpdf] to make individual pdfs for each of the lab exercises."

121: 121-h 121-p

html: setup-h 121-h

latex: setup-l 121-l

pdf: 121-p setup-p

checksize:
	@echo "Building list.one and list.two..."
	@echo "#!/bin/sh" > list.one
	@echo "#!/bin/sh" > list.two
	@grep "PDF version" 121-Lab-Manual.xml | sed 's#.*\">\(.*\)\.pdf (\([0-9][0-9]*\) kB.*#echo "echo -e \\\"claim: \2\\\\tactual:\\\" \\\\`expr `stat --printf=%s \1.pdf` / 1000\\\\`\\\\\t\1" >> list.two#g' >> list.one 
	./list.one 
	./list.two

fixsize:
	@echo "Building step.one and step.two..."
	@echo "#!/bin/sh" > step.one
	@echo "#!/bin/sh" > step.two
	@grep "PDF version" 121-Lab-Manual.xml | sed 's#.*\">\(.*\)\.pdf (\([0-9][0-9]*\) kB.*#echo "echo \\"s^\1.pdf (\2 kB)^\1.pdf (\\\\`expr `stat --printf=%s \1.pdf` / 1000\\\\` kB)^g\\"" >> step.two#g' >> step.one 
	./step.one 
	./step.two > step.sed
	sed -i.size -f step.sed 121-Lab-Manual.xml

fall-lab-manual.pdf: 121-p

buildpdfs: fall-lab-manual.pdf
	@echo "Creating scripttolistbyname... (print at end)"
	@echo "#!/bin/sh" > scripttolistbyname
	@grep "chapter" fall-lab-manual.toc | \
		sed -n 'N;l;D' | \
		sed ':x ; $$!N ; s/\\\\\n// ; tx ; P ; D' | \
		grep -v "chapter\*" | \
		sed 's/\(.*\)\$$/\1/g' | \
		sed 's/.*{.*}{.*{.*}.\{3\}\(.*\)}{\([0-9][0-9]*\)}{\(.*\)}.*{.*}{.*{.*}.*}{\([0-9][0-9]*\)}{.*}/grep \"\1\\}\\\\\\\\\\\\\\\\label\" fall-lab-manual.tex \| sed \x22s#.\*label{\\\\(.\*\\\\)}#\3: `expr \2 + 12`..`expr \4 + 11`\\\\t\\\\1#g\x22 \| sed \x27s#c-##g\x27/g' \
		>> scripttolistbyname
	@echo "Creating buildscript..."
	@echo "#!/bin/sh" > buildscript
	@grep "chapter" fall-lab-manual.toc | \
		sed -n 'N;l;D' | \
		sed ':x ; $$!N ; s/\\\\\n// ; tx ; P ; D' | \
		grep -v "chapter\*" | \
		sed 's/\(.*\)\$$/\1/g' | \
		sed 's/.*{.*}{.*{.*}.\{3\}\(.*\)}{\([0-9][0-9]*\)}{\(.*\)}.*{.*}{.*{.*}.*}{\([0-9][0-9]*\)}{.*}/grep \"\1\\}\\\\\\\\\\\\\\\\label\" fall-lab-manual.tex \| sed \x22s#c-##g\x22 \| sed \x22s#.\*label{\\\\(.\*\\\\)}#pdfseparate -f `expr \2 + 12` -l `expr \4 + 11` fall-lab-manual.pdf \\\\1.\%d.pdf ; rm \\\\1_big.pdf \\\\1.pdf ; pdfunite \\\\1.*.pdf \\\\1_big.pdf ; rm \\\\1.*.pdf ; ps2pdf \\\\1_big.pdf \\\\1.pdf#g\x22/g' \
		>> buildscript
	@echo "#!/bin/sh" > buildpdfs
	@echo "Using buildscript to create buildpdfs..."
	./buildscript >> buildpdfs
	@echo "Running buildpdfs to create the lab pdfs."
	./buildpdfs 2> /dev/null
	./scripttolistbyname
	@echo "You need to use PDFsam to fix the labs with pictures: measurement and StDev."
	@/c/Program\ Files\ \(x86\)/PDFsam\ Basic/bin/pdfsam.sh -e ./fall-lab-manual.pdf 2> /dev/null &
	@echo -e "I am running PDFsam, you should do this:\nextract pages listed\nmv PDFsam_fall-lab-manual.pdf measurement.pdf\nextract pages for StDev\nmv PDFsam_fall-lab-manual.pdf StDev.pdf\nextract all pages (to compress the full manual)\nmv PDFsam_fall-lab-manual.pdf fall-lab-manual.pdf\nmake checksize\nmake fixsize\n./scripttolistbyname"

labpdf: buildpdfs

images: 121-Lab-Manual.xml Lab-setup-121.xml
	${BEE}/script/mbx -v -c latex-image -f svg -d images ${AIY}/121-Lab-Manual.xml
#	${BEE}/script/mbx -v -c latex-image -r [specific image reference] -f svg -d images ${AIY}/121-Lab-Manual.xml
	${BEE}/script/mbx -v -c latex-image -f svg -d images ${AIY}/Lab-setup-121.xml


# To list the images in the xml and print a line that will check to see if that image exists and (if not) try to create the image...

list: 121-Lab-Manual.xml Lab-setup-121.xml
	cat Lab-setup-121.xml | \
		sed 's/^ *<image/<image/g' | \
		grep '<image' | grep -v "images" | \
		sed 's/ width=.*>/>/g' | \
		sed 's+^.*xml:id=\"\(.*\)\">+ls images/\1.svg || C:/Users/tensen/Desktop/Book/mathbook/script/mbx \-v \-c latex-image \-r \1 \-f svg \-d images ${AIY}/Lab-setup-121.xml+g'
	@echo "*************************"
	cat 121-Lab-Manual.xml | \
		sed 's/^ *<image/<image/g' | \
		grep '<image' | grep -v "images" | \
		sed 's/ width=.*>/>/g' | \
		sed 's+^.*xml:id=\"\(.*\)\">+ls images/\1.svg || C:/Users/tensen/Desktop/Book/mathbook/script/mbx \-v \-c latex-image \-r \1 \-f svg \-d images ${AIY}/121-Lab-Manual.xml+g'

counterr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml  Lab-setup-121.xml
	@echo `java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng Lab-setup-121.xml | wc -l`" errors"
	@echo `java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml | wc -l`" errors"

toperr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml  Lab-setup-121.xml
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng Lab-setup-121.xml | head -5
	@echo "*************************"
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml | head -5

typeerr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml  Lab-setup-121.xml
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng Lab-setup-121.xml | \
		sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\): error: element "\([a-zA-Z][a-zA-Z]*\)".*/\3 line \1:\2/g' | \
		sort -k1
	@echo "*************************"
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml | \
		sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\): error: element "\([a-zA-Z][a-zA-Z]*\)".*/\3 line \1:\2/g' | \
		sort -k1

# To find the errors on "todo"  (must change in two places)                                                vvvv                                                 vvvv
# 	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml | grep ": element \"todo" | sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\):.*/todo line \1:\2/g'
#                                                                                                          ^^^^                                                 ^^^^

allerr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml  Lab-setup-121.xml
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng Lab-setup-121.xml | \
		sort -k4  
	@echo "*************************"
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml | \
		grep -v `grep -n "known tag abuse 1" 121-Lab-Manual.xml | sed 's/:.*//g'` | \
		sort -k4  

all: setup-h 121-h setup-l 121-l images
