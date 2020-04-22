function! typewriting#SetProseUndoPoints()
    " set undo points around common punctuation,
    " line <c-u> and word <c-w> deletions
    if b:prose_mode
        ino <buffer> . .<c-g>u
        ino <buffer> ! !<c-g>u
        ino <buffer> ? ?<c-g>u
        ino <buffer> , ,<c-g>u
        ino <buffer> ; ;<c-g>u
        ino <buffer> : :<c-g>u
        ino <buffer> <c-u> <c-g>u<c-u>
        ino <buffer> <c-w> <c-g>u<c-w>

        " map <cr> only if not already mapped
        if empty(maparg('<cr>', 'i'))
            ino <buffer> <cr> <c-g>u<cr>
            let b:prose_cr_mapped = 1
        el
            let b:prose_cr_mapped = 0
        en
    el
        sil! iu <buffer> .
        sil! iu <buffer> !
        sil! iu <buffer> ?
        sil! iu <buffer> ,
        sil! iu <buffer> ;
        sil! iu <buffer> :
        sil! iu <buffer> <c-u>
        sil! iu <buffer> <c-w>

        " unmap <cr> only if we mapped it ourselves
        if exists('b:prose_cr_mapped') && b:prose_cr_mapped
            sil! iu <buffer> <cr>
        en
    en
endfunction

function! typewriting#ForwardOnlyMode(...)
	" If bang!
	if a:0 > 0 && a:1 == 1
        "Re-enable backspace
        silent! iunmap <BS>
        silent! iunmap <Del>
    else
        "Disable backspace
        inoremap <BS> <Nop>
        inoremap <Del> <Nop>
    endif
endfunc

function! typewriting#Prose()
    let b:prose_mode = 1
    call typewriting#SetProseUndoPoints()
    set spell spelllang=en_us
    hi SpellBad gui=underline
    hi SpellRare gui=underline
    hi SpellCap gui=underline
    hi SpellLocal gui=underline
    set nofoldenable
    set nocursorline
    set wrap

    let user_dict = {
      \ 'sentence': ['sentance'],
      \ }

    call litecorrect#init(user_dict)
    call textobj#sentence#init()
endfunction

function! typewriting#Minimal(...)
	" If bang!
	if a:0 > 0 && a:1 == 1
        Goyo!
        silent !tmux set -t $TMUX_PANE status on
        call typewriting#ForwardOnlyMode(1)
        set conceallevel=2
        set showcmd
        hi SpellBad gui=underline
        hi SpellRare gui=underline
        hi SpellCap gui=underline
        hi SpellLocal gui=underline
        let l:cursor_pos = getpos(".")
        Limelight!
        call setpos('.', l:cursor_pos)
    else
        Goyo 84
        silent !tmux set -t $TMUX_PANE status off
        call typewriting#ForwardOnlyMode()
        hi clear SpellBad
        set noshowcmd
        hi clear SpellRare
        hi clear SpellCap
        hi clear SpellLocal
        set conceallevel=0
        let l:cursor_pos = getpos(".")
        Limelight
        call setpos('.', l:cursor_pos)
    endif
endfunction

function! typewriting#SoftWrite(...)
	" If bang!
	if a:0 > 0 && a:1 == 1
        Goyo!
    else
        Goyo 78-40%x100%
    endif
endfunction

function! typewriting#OpenDraft()
    let d = expand('%:p:h')
    if d =~ "website/content"
        let p = expand('%:p:h:t') . '/'
        if p == 'content/'
            " Reset p to root
            let p = ''
        endif
        let n = expand('%:t:r')
        let url = 'http://127.0.0.1:5000/' . p . n . '.html'
        if has('mac')
            silent! execute '!open ' . url
        else
            silent! execute '! xdg-open ' . url
        endif
    else
        echoerr "Error: Not in writing directory!"
    endif
endfunction

function! typewriting#TogglePandocModeMappings()
    if g:pandoc#formatting#mode == "s"
        nn <buffer> <silent> j gj
        nn <buffer> <silent> k gk
        vn <buffer> <silent> j gj
        vn <buffer> <silent> k gk
    el
        sil! nun <buffer> j
        sil! nun <buffer> k
        sil! vu  <buffer> j
        sil! vu  <buffer> k
    en
endfunction

" Print markdown draft using pandoc
function! typewriting#PrintDraft(...)
  let l:filename = expand('%:p')
  " If bang! save to file
  if a:0 > 0 && a:1 == 1
    "do not print
    exec "!pd -d " . l:filename
  elseif exists('a:2')
    exec "!pd -p " . a:2  l:filename
  else
    exec "!pd " . l:filename
  endif
endfunction
