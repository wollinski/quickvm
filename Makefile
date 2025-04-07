userconfig = $(HOME)/.config/quickvm

templatepath = $(userconfig)/templates
cloudinittemplatepath = $(templatepath)/cloudinit

libpath = /usr/local/lib/quickvm

keyringpath = /usr/local/share/quickvm/ubuntu-signingkey.gpg

$(templatepath):
	@echo "creating template dir"
	mkdir -p $(templatepath)

$(cloudinittemplatepath): | $(templatepath)
	@echo "creating dir for cloud init templates"
	mkdir -p $(cloudinittemplatepath)

$(cloudinittemplatepath)/user-data.tpl: | $(cloudinittemplatepath)
	cp templates/cloudinit/user-data.tpl $(cloudinittemplatepath)

$(cloudinittemplatepath)/meta-data.tpl: | $(cloudinittemplatepath)
	cp templates/cloudinit/meta-data.tpl $(cloudinittemplatepath)

.PHONY: cloudinit-templates
cloudinit-templates: $(cloudinittemplatepath)/user-data.tpl $(cloudinittemplatepath)/meta-data.tpl

.PHONY: templates
templates: cloudinit-templates
	@echo "target templates"

$(libpath):
	@echo "creating lib dir"
	mkdir -p $(libpath)

$(libpath)/validateImage.sh: | $(libpath)
	cp lib/validateImage.sh $(libpath)

.PHONY: lib
lib: $(libpath)/validateImage.sh

# https://wiki.ubuntu.com/SecurityTeam/FAQ#GPG_Keys_used_by_Ubuntu
$(keyringpath):
	@mkdir -p `dirname $(keyringpath)`
	@gpg --dearmor --output $(keyringpath) ubuntu-signingkey.asc

.PHONY: keyring
keyring: $(keyringpath)