" Disable backspace and delete
command! -nargs=* -bang ForwardOnlyMode call typewriting#ForwardOnlyMode(<bang>0)

"Set prose-specific settings
function! Prose()
    call typewriting#Prose()
endfunction
command! -nargs=0 Prose call typewriting#Prose()

" Print draft
command! -nargs=* -bang PrintDraft call typewriting#PrintDraft(<bang>0, <f-args>)

" Configure goyo for distraction-free
command! -nargs=* -bang Minimal call typewriting#Minimal(<bang>0)

command! -nargs=* -bang SoftWrite call typewriting#SoftWrite(<bang>0)

" Run :FixQuotes to substitute curly quotes for straight quotes.
function! s:FixQuotes(line1,line2)
    let l:save_cursor = getpos(".")
    silent! execute ':' . a:line1 . ',' . a:line2 . 's/[“”]/"/g'
    silent! execute ':' . a:line1 . ',' . a:line2 . "s/[‘’]/'/g"
    call setpos('.', l:save_cursor)
endfunction
command! -range=% FixQuotes call <SID>FixQuotes(<line1>,<line2>)

" Open draft
function! OpenDraft()
    call typewriting#OpenDraft()
endfunction    
command! -nargs=0 OpenDraft call OpenDraft()

" Return wc
function! Wc()
    let wc = system("wc -w < " . expand('%'))
    echom substitute(wc, '\n\+$', '', '')
endfunction
command! -nargs=0 Wc call Wc()

" Return git wc
function! Gwc()
    let wc = system("git wc")
    echom substitute(wc, '\n\+$', '', '')
endfunction
command! -nargs=0 Gwc call Gwc()

" Lifted from vim-pencils
" https://github.com/reedes/vim-pencil/blob/master/autoload/pencil.vim

" ----------------------------------------------------------------------------
" Skeleton Templates with UltiSnips
" ----------------------------------------------------------------------------

augroup ultisnips_custom
  autocmd!
  autocmd BufNewFile * silent! call typewriting#InsertSkeleton()
augroup END

function! typewriting#InsertSkeleton() abort
  let filename = expand('%')

  " Abort on non-empty buffer or extant file
  if !(line('$') == 1 && getline('$') == '') || filereadable(filename)
    return
  endif

  call s:try_insert('skel')
endfunction

function! s:try_insert(skel)
  execute "normal! i_" . a:skel . "\<C-r>=UltiSnips#ExpandSnippet()\<CR>"

  if g:ulti_expand_res == 0
    silent! undo
  endif

  return g:ulti_expand_res
endfunction
