# Lab Manual and Set-up Instructions

default: 
	@echo "make -n ... to display commands with running"
	@echo "make -s ... to not display commands when running them"
	@echo "Choices: setup-h, setup-l, 121-h, 121-l, images, list (prints copy-paste select image creation), counterr, toperr, typeerr, allerr"
	@echo "make all will make all html, all latex, and images"

git: 
	git diff-index --stat master

mathbook-setup-latex.xsl: 
	git diff-index --name-only master | grep mathbook-setup-latex.xsl && git diff-index --stat master 

mathbook-setup-html.xsl: 
	git diff-index --name-only master | grep mathbook-setup-html.xsl && git diff-index --stat master

mathbook-121-latex.xsl: 
	git diff-index --name-only master | grep mathbook-121-latex.xsl && git diff-index --stat master 

mathbook-121-html.xsl: 
	git diff-index --name-only master | grep mathbook-121-html.xsl && git diff-index --stat master

Lab-setup-121.xml:
	git diff-index --name-only master | grep Lab-setup-121.xml && git diff-index --stat master

121-Lab-Manual.xml:
	git diff-index --name-only master | grep 121-Lab-Manual.xml && git diff-index --stat master


${BEE}/user/mathbook-setup-latex.xsl: mathbook-setup-latex.xsl
	cp mathbook-setup-latex.xsl ${BEE}/user/

${BEE}/user/mathbook-setup-html.xsl: mathbook-setup-html.xsl
	cp mathbook-setup-html.xsl ${BEE}/user/

${BEE}/user/mathbook-121-latex.xsl: mathbook-121-latex.xsl
	cp mathbook-121-latex.xsl ${BEE}/user/

${BEE}/user/mathbook-121-html.xsl: mathbook-121-html.xsl
	cp mathbook-121-html.xsl ${BEE}/user/

setup-h: ${BEE}/user/mathbook-setup-html.xsl Lab-setup-121.xml 
	xsltproc ${BEE}/user/mathbook-setup-html.xsl Lab-setup-121.xml

setup-l: ${BEE}/user/mathbook-setup-latex.xsl Lab-setup-121.xml 
	xsltproc ${BEE}/user/mathbook-setup-latex.xsl Lab-setup-121.xml
	echo "Use WindEdt to pdflatex"

setup: setup-h setup-l


121-h: ${BEE}/user/mathbook-121-html.xsl 121-Lab-Manual.xml
	xsltproc ${BEE}/user/mathbook-121-html.xsl 121-Lab-Manual.xml

121-l: ${BEE}/user/mathbook-121-latex.xsl 121-Lab-Manual.xml
	xsltproc ${BEE}/user/mathbook-121-latex.xsl 121-Lab-Manual.xml
	@echo "Use WindEdt to pdflatex"
	@echo "Change the tocdepth to zero"
	@echo "Remove the Capstone assemblage"

121: 121-h 121-l

html: setup-h 121-h

latex: setup-l 121-l

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
		sort -k4  

all: setup-h 121-h setup-l 121-l images
