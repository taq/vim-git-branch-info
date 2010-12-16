zip:
	git archive --format=zip HEAD plugin/*.vim > vim-git-branch-info.zip
install:
	mkdir -p ~/.vim/plugin/
	cp git-branch-info.vim ~/.vim/plugin/
