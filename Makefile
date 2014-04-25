SITEDOCS = $(patsubst %.md,%.html,$(wildcard *.md))

all: man.mk
	make html

-include man.mk

html: index.html $(MAN2HTML) $(SITEDOCS)

$(MAN2HTML): %.html : %.pm template.html.tt page.pl
	@echo "$< → $@"
	@((echo "<h1>$$(basename $@ | sed 's/.html//')</h1>"; pod2html --noindex $< | sed -s '1,/<body/ d; /<\/body>/,$$ d') | perl page.pl $@ > $@) || ($(RM) $@; false)

$(SITEDOCS): %.html : %.md template.html.tt page.pl
	@echo "$< -> $@"
	@mkdir -p $$(dirname $@)
	@(pandoc -f markdown -t html $< | perl page.pl $@ > $@) || ($(RM) $@; false)

man.mk: man.pl
	perl $< > $@

upload: all
	rsync \
		-avp \
		--delete \
		--copy-links \
		--exclude '*.swp' \
		--exclude '*.pm' \
		--exclude '*.md' \
		--exclude '*.pl' \
		--exclude '*.mk' \
		--exclude '*.tt' \
		--exclude Makefile \
		./ analizo.org:analizo/

clean:
	$(RM) man.mk $(MAN)
	$(RM) index.html
	$(RM) $(SITEDOCS)
	$(RM) -r man
	$(RM) pod2htmd.tmp
	$(RM) $(CLEAN)
