scriptencoding utf-8

if exists('g:loaded_closesubwin')
  finish
endif
let g:loaded_closesubwin = 1

let s:save_cpo = &cpo
set cpo&vim

nmap <silent> <Plug>(closesubwin-close-help)
\   :<C-u>call closesubwin#close_help_window()<CR>
nmap <silent> <Plug>(closesubwin-close-quickfix)
\   :<C-u>call closesubwin#close_quickfix_window()<CR>
nmap <silent> <Plug>(closesubwin-close-unlisted)
\   :<C-u>call closesubwin#close_unlisted_window()<CR>

" Close first matching window in above windows.
nmap <silent> <Plug>(closesubwin-close-sub)
\   :<C-u>call closesubwin#close_sub_window()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set et:
