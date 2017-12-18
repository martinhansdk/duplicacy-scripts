#
# Makefie for Duplicacy Scripts
#

# Configure the following to taste.

# Suitable for general use:

# Root of backup
ROOT=/

# Where the scripts and data should be installed
DEST=/local/duplicacy

# Suitable for experimentation in /tmp
#ROOT=/tmp
#DEST=/tmp/duplicacy-scripts

DUPLICACY_BINARY=duplicacy_linux_x64_2.0.10


# No user-serviceable parts below this point.


BIN=$(DEST)/bin
ETC=$(DEST)/etc
LIB=$(DEST)/lib
PREFS=$(DEST)/prefs


default:
	@echo Nothing to do.


$(DEST):
	mkdir -p $@

$(DEST)/%:
	mkdir -p $@

# File that points Duplicacy at its local storage
LOCATION_FILE=$(ROOT)/.duplicacy
$(LOCATION_FILE): $(ROOT)
	echo "$(DEST)/prefs" > $@


# Duplicacy binary.
$(BIN)/$(DUPLICACY_BINARY): $(DUPLICACY_BINARY) $(BIN)
	rm -f $@
	cp $< $@
	chmod 555 $@

$(BIN)/duplicacy: $(BIN)/$(DUPLICACY_BINARY) $(BIN)
	rm -f $@
	ln -s $(DUPLICACY_BINARY) $@


# Crontab
CRONTAB=$(LIB)/crontab
$(CRONTAB): lib/crontab $(LIB) 
	sed -e 's|__TOP__|$(DEST)|g' $< > $@

install: $(BIN) $(BIN)/duplicacy $(ETC) $(LIB) $(CRONTAB) \
	$(PREFS) $(LOCATION_FILE)
	cp -r bin/* $(BIN)
	cp -r etc/* $(ETC)
	ln -s "$(ROOT)" $(DEST)/root
	VISUAL=$(BIN)/crontab-install crontab -e

update:
	git pull
	$(MAKE) install

uninstall:
	VISUAL=$(BIN)/crontab-remove crontab -e
	@echo "Note:  All this did was disable the cron jobs."


clean:
	rm -rf $(TO_CLEAN)
	find . -name "*~" | xargs rm -f
