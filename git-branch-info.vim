"
" Git branch info
" Last change: June 5 2008
" Version> 0.0.1
" Maintainer: Eustáquio 'TaQ' Rangel
" License: GPL
" URL: git://github.com/taq/vim-git-branch-info.git
"
" This plugin show branches information on the status line.
" To install, just put this file on ~/.vim/plugins and set your status line:
"
" :set statusline=%{GitBranchInfoString}
"
" Of course you can append this configuration to an existing one and make all 
" the customization you want on the status line, like:
"
" :set statusline=%#ErrorMsg#%{GitBranchInfoString}%#StatusLine#
"
" The command above will show the Git branches info on the same color as the
" error messages. You can choose any color scheme you want to. Use
"
" :help highlight-groups
"
" to check for some other options.
"
" There are some customization on the result string based on existing variables 
" like:
"
" let g:git_branch_status_all=1
" This will show all the existing branches with the current branch first
" 
" let g:git_branch_status_text="text"
" This will show 'text' before the branches. If not set ' Git ' (with a trailing
" left space) will be displayed.
"
" let g:git_branch_status_nogit=""
" The message when there is no Git repository on the current dir
"
" let g:git_branch_status_around=""
" Characters to put around the branch strings. Need to be a pair or characters,
" the first will be on the beginning of the branch string and the last on the
" end.
" 
" If you want to make your own customizations, you can use the GitBranchInfoTokens()
" function. It returns an array with the current branch as the first element and
" another array with the other branches as the second element, like:
"
" :set statusline=%#ErrorMsg#%{GitBranchInfoTokens[0]}%#StatusLine#
"
" or
"
" :set statusline=%#StatusLineNC#\ Git\ %#ErrorMsg#\ %{GitBranchInfoTokens[0]}\ %#StatusLine#
"
" will give you a nice custom formatted string.
"
" This will show you the current branch only. No prefix text, no characters
" around it. You can also make another functions to use the returned array.
"

function GitBranchInfoString()
	let s:tokens	= GitBranchInfoTokens()	" get the tokens
	if len(s:tokens)==1							" no git here
		return s:tokens[0]
	end
	let s:current	= s:tokens[0]				" the current branch is the first one
	let s:branches	= s:tokens[1]				" the other branches are the last one
	" check for around characters
	let s:around	= exists("g:git_branch_status_around") ? (strlen(g:git_branch_status_around)==2 ? split(g:git_branch_status_around,'\zs') : ["",""]) : ["[","]"]
	" find the prefix text
	let s:text		= exists("g:git_branch_status_text")   ? g:git_branch_status_text : " Git "
	return s:text.s:around[0].s:current.s:around[1].(exists("g:git_branch_status_all")?s:around[0].join(s:branches,",").s:around[1]:"")
endfunction

function GitBranchInfoTokens()
	" check if the .git directory exists
	if empty(finddir(".git")) 
		return [exists("g:git_branch_status_nogit") ? g:git_branch_status_nogit : "No git."]
	endif
	let s:cmd		= system("git\ branch\ \-a")					" execute the system command
	if strlen(s:cmd)==0													" if there is nothing yet return default values
		return ["master",[]]												" a master branch and no more branches
	endif
	let s:branches = split(s:cmd,"\n")								" get all the branches
	let s:curidx   = match(s:branches,"^*")						" find the current branch index
	call map(s:branches,'substitute(v:val,"^[ \*]*","","")')	" remove the white spaces and star from list
	let s:current	= remove(s:branches,s:curidx)					" get the current branch name
	return [s:current,s:branches]										" return the tokens
endfunction
