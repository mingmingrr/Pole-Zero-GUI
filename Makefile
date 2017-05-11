lssrc = $(shell find scripts/ -type f -name '*.ls')
jsobj = $(lssrc:.ls=.js)
packobj = app.js vendor.js

csssrc = $(shell find styles/ -type f -name '*.styl')
cssobj = $(csssrc:.styl=.css)

htmlsrc = $(shell find . -maxdepth 1 -type f -name '*.pug')
htmlobj = $(htmlsrc:.pug=.html)

testsrc = $(shell find test/ -type f -name '*.ls')
testobj = $(testsrc:.ls=.js)

confsrc = $(shell find . -maxdepth 1 -type f -name '*.ls')
confobj = $(confsrc:.ls=.js)

.PHONY: all
all: compile pack

.PHONY: compile
compile: $(jsobj) $(cssobj) $(htmlobj)

.PHONY: config
config: $(confobj)

.PHONY: pack
pack: compile config
	webpack

$(packobj): compile config
	webpack

$(jsobj) $(testobj) $(confobj): %.js: %.ls
	lsc -pcb $< > $@

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

