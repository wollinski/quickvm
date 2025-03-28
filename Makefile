userconfig = $(HOME)/.config/quickvm

templatepath = $(userconfig)/templates
cloudinittemplatepath = $(templatepath)/cloudinit

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
