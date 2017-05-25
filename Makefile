lssrc = $(shell find scripts/ -type f -name '*.ls')
jsobj = $(lssrc:.ls=.js)

packobj = app.js vendor.js
packflag = -d

csssrc = $(shell find styles/ -type f -name '*.styl')
cssobj = $(csssrc:.styl=.css)

htmlsrc = $(shell find . -maxdepth 1 -type f -name '*.pug')
htmlobj = $(htmlsrc:.pug=.html)

testsrc = $(shell find test/ -type f -name '*.ls')
testobj = $(testsrc:.ls=.js)

confsrc = $(shell find . -maxdepth 1 -type f -name '*.ls')
confobj = $(confsrc:.ls=.js)

releasedir = release/

.PHONY: all
all: compile pack

.PHONY: compile
compile: $(jsobj) $(cssobj) $(htmlobj)

.PHONY: config
config: $(confobj)

.PHONY: pack
pack: compile config
	webpack --progress $(packflag)

.PHONY: release
release: packflag = -p
release: all
	echo $(packflag)
	mkdir -p $(releasedir)
	cp --parents $(packobj) $(cssobj) $(htmlobj) $(releasedir)
	cd $(releasedir); zip -r9 ../release.zip *
	cd $(releasedir); tar -zcvf ../release.tar.gz *

.PHONY: watch
watch: config
	webpack --watch &
	while true; do make --quiet compile; sleep 1; done

$(packobj): compile config
	webpack

$(jsobj) $(testobj) $(confobj): %.js: %.ls
	lsc -pcb $< > $@
	@echo -e '  \033[1;30mcompiled\033[0m $<'

$(cssobj): %.css: %.styl
	stylus $<

$(htmlobj): %.html: %.pug
	pug -n $@ -P $<

.PHONY: test
test: compile $(testobj)
	mocha

.PHONY: clean
clean:
	@rm -vf $(jsobj)
	@rm -vf $(cssobj)
	@rm -vf $(testobj)
	@rm -vf $(htmlobj)
	@rm -vf $(confobj)
	@rm -vf $(packobj)
	@rm -vfr $(releasedir)
	@rm -vf release.zip release.tar.gz

