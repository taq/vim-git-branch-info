"
" Git branch info
" Last change: June 5 2008
" Version> 0.0.3
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
let s:menu_on	= 0
let s:checking = ""

function GitBranchInfoRenewMenu(current,heads,remotes)
	call GitBranchInfoRemoveMenu()
	call GitBranchInfoShowMenu(a:current,a:heads,a:remotes)
endfunction

function GitBranchInfoCheckout(branch)
	let l:tokens = GitBranchInfoTokens()
	exe "!git\ checkout\ ".a:branch
	call GitBranchInfoRenewMenu(l:tokens[0],l:tokens[1],l:tokens[2])
endfunction

function GitBranchInfoShowMenu(current,heads,remotes)
	if !has("gui")
		return
	endif
	let s:menu_on	= 1
	let l:compare	= a:current
	let l:current	= [a:current]
	let l:heads		= len(a:heads)>0	 ? a:heads	 : []
	let l:remotes	= len(a:remotes)>0 ? a:remotes : []
	let l:locals	= sort(extend(l:current,l:heads))
	for l:branch in l:locals
		let l:moption	= (l:branch==l:compare ? "*\\ " : "\-\\ ").l:branch
		let l:mcom		= (l:branch==l:compare ? ":echo 'Already\ on\ branch\ \''".l:branch."\''.'<CR>" : "call GitBranchInfoCheckout('".l:branch."')<CR><CR>")
		exe ":menu Plugin.Git\\ Info.".l:moption." :".l:mcom
	endfor
	exe ":menu Plugin.Git\\ Info.-Local- :"
	for l:branch in l:remotes
		exe "menu Plugin.Git\\ Info.".l:branch." :echo 'No fetch feature yet.'<CR>"
	endfor
endfunction

function GitBranchInfoRemoveMenu()
	if !has("gui") || s:menu_on==0
		return
	endif
	exe ":unmenu Plugin.Git\\ Info" 
	let s:menu_on = 0
endfunction

function GitBranchInfoString()
	let l:tokens	= GitBranchInfoTokens()	" get the tokens
	if len(l:tokens)==1							" no git here
		call GitBranchInfoRemoveMenu()
		return l:tokens[0]
	end
	let s:current	= l:tokens[0]				" the current branch is the first one
	let l:branches	= l:tokens[1]				" the other branches are the last one
	let l:remotes	= l:tokens[2]				" remote branches
	" check for around characters
	let l:around	= exists("g:git_branch_status_around") ? (strlen(g:git_branch_status_around)==2 ? split(g:git_branch_status_around,'\zs') : ["",""]) : ["[","]"]
	" find the prefix text
	let l:text		= exists("g:git_branch_status_text")   ? g:git_branch_status_text : " Git "
	if s:menu_on == 0
		call GitBranchInfoShowMenu(l:tokens[0],l:tokens[1],l:tokens[2])
	endif
	return l:text.l:around[0].s:current.l:around[1].(exists("g:git_branch_status_head_current")?"":l:around[0].join(l:branches,",").l:around[1])
endfunction

function GitBranchInfoTokens()
	if empty(finddir(".git"))
		return [exists("g:git_branch_status_nogit") ? g:git_branch_status_nogit : "No git."]
	endif
	let s:current	= split(split(readfile(".git/HEAD",'',1)[0])[1],"/")[2]
	if exists("g:git_branch_status_head_current")
		let l:heads	= []
	else		
		let l:heads	= split(glob(".git/refs/heads/*"),"\n")
		call map(l:heads,'substitute(v:val,".git/refs/heads/","","")')
		call sort(filter(l:heads,'v:val !~ s:current'))
	endif		
	if exists("g:git_branch_status_ignore_remotes")
		let l:remotes = []
	else
		let l:remotes	= split(glob(".git/refs/remotes/*/**"),"\n")
		call sort(map(l:remotes,'substitute(v:val,".git/refs/remotes/","","")'))
	endif		
	let l:checking = s:current.join(l:heads).join(l:remotes)
	if l:checking != s:checking && has("gui")
		call GitBranchInfoRenewMenu(s:current,l:heads,l:remotes)
	endif
	let s:checking = l:checking
	return [s:current,l:heads,l:remotes]
endfunction
