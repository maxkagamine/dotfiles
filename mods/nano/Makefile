nano::
	$(PRINT)
	$(info Patching sh.nanorc to enable syntax highlighting of Ctrl+X,Ctrl+E (edit-and-execute-command))
	sudo sed -Ei 's/^(syntax sh .*\$$)"$$/\1\|\^\/tmp\/bash-"/' /usr/share/nano/sh.nanorc
