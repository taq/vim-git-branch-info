zip:
	git archive --format=zip --prefix=plugin/ HEAD *.vim > vim-git-branch-info.zip
install:
	mkdir -p ~/.vim/plugin/
	cp git-branch-info.vim ~/.vim/plugin/
