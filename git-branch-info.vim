"
" Git branch info
" Last change: June 5 2008
" Version> 0.0.2
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
" let g:git_branch_status_head_current=1
" This will show just the current head branch name 
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
" let g:git_branch_status_ignore_remotes=1
" Ignore the remote branches. If you don't want information about them, this can
" make things works faster.
"
" If you want to make your own customizations, you can use the GitBranchInfoTokens()
" function. It returns an array with the current branch as the first element and
" another array with the other branches as the second element, like:
"
" :set statusline=%#ErrorMsg#%{GitBranchInfoTokens()[0]}%#StatusLine#
"
" or
"
" :set statusline=%#StatusLineNC#\ Git\ %#ErrorMsg#\ %{GitBranchInfoTokens()[0]}\ %#StatusLine#
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
	let s:remotes	= s:tokens[2]				" remote branches
	" check for around characters
	let s:around	= exists("g:git_branch_status_around") ? (strlen(g:git_branch_status_around)==2 ? split(g:git_branch_status_around,'\zs') : ["",""]) : ["[","]"]
	" find the prefix text
	let s:text		= exists("g:git_branch_status_text")   ? g:git_branch_status_text : " Git "
	return s:text.s:around[0].s:current.s:around[1].(exists("g:git_branch_status_head_current")?"":s:around[0].join(s:branches,",").s:around[1])
endfunction

function GitBranchInfoTokens()
	if empty(finddir(".git"))
		return [exists("g:git_branch_status_nogit") ? g:git_branch_status_nogit : "No git."]
	endif
	let s:current	= split(split(readfile(".git/HEAD",'',1)[0])[1],"/")[2]
	if exists("g:git_branch_status_head_current")
		let s:heads	= []
	else		
		let s:heads	= split(glob(".git/refs/heads/*"),"\n")
		call map(s:heads,'substitute(v:val,".git/refs/heads/","","")')
		call sort(filter(s:heads,'v:val !~ s:current'))
	endif		
	if exists("g:git_branch_status_ignore_remotes")
		let s:remotes = []
	else
		let s:remotes	= split(glob(".git/refs/remotes/*/**"),"\n")
		call sort(map(s:remotes,'substitute(v:val,".git/refs/remotes/","","")'))
	endif		
	return [s:current,s:heads,s:remotes]
endfunction
