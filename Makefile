zip:
	git archive --format=zip --prefix=plugin/ HEAD > vim-git-branch-info.zip
install:
	cp git-branch-info.vim ~/.vim/plugin/
