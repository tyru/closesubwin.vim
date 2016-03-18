scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! closesubwin#close_help_window() abort
    helpclose
endfunction

function! closesubwin#close_quickfix_window() abort
    cclose
endfunction

function! closesubwin#close_unlisted_window() abort
    return s:window.close_first_like('s:is_unlisted_window(winnr)')
endfunction

function! closesubwin#close_sub_window() abort
    let curwinnr = winnr()
    let groups = s:window.get_all_groups()

    " Close current.
    for group in groups
        if group.detect(curwinnr)
            call group.close()
            return
        endif
    endfor

    " Or close outside buffer.
    for group in groups
        if group.close()
            return 1
        endif
    endfor
endfunction


" =============== s:window ===============
let s:window = {'_group_order': [], '_groups': {}}

function! s:window.register(group_name, functions) abort
    call add(s:window._group_order, a:group_name)
    let s:window._groups[a:group_name] = a:functions
endfunction

function! s:window.get_all_groups() abort
    return map(copy(s:window._group_order),
    \         'deepcopy(s:window._groups[v:val])')
endfunction

function! s:window.close(winnr) abort
    if winbufnr(a:winnr) !=# -1
        execute a:winnr . 'wincmd w'
        execute 'wincmd c'
        return 1
    else
        return 0
    endif
endfunction

function! s:window.get_winnr_list_like(expr) abort
    let ret = []
    for winnr in range(1, winnr('$'))
        if eval(a:expr)
            call add(ret, winnr)
        endif
    endfor
    return ret
endfunction

function! s:window.close_first_like(expr) abort
    let winnr_list = s:window.get_winnr_list_like(a:expr)
    " Close current window if current matches a:expr.
    let winnr_list = s:move_current_winnr_to_head(winnr_list)
    if empty(winnr_list)
        return
    endif

    let prev_winnr = winnr()
    try
        for winnr in winnr_list
            if s:window.close(winnr)
                return 1    " closed.
            endif
        endfor
        return 0
    finally
        " Back to previous window.
        let cur_winnr = winnr()
        if cur_winnr !=# prev_winnr && winbufnr(prev_winnr) !=# -1
            execute prev_winnr . 'wincmd w'
        endif
    endtry
endfunction

function! s:move_current_winnr_to_head(winnr_list) abort
    let winnr = winnr()
    if index(a:winnr_list, winnr) is -1
        return a:winnr_list
    endif
    return [winnr] + filter(a:winnr_list, 'v:val isnot winnr')
endfunction


" =============== help ===============

function! s:is_help_window(winnr) abort
    return getbufvar(winbufnr(a:winnr), '&buftype') ==# 'help'
endfunction

call s:window.register('help', {'close': function('closesubwin#close_help_window'), 'detect': function('s:is_help_window')})

" =============== quickfix ===============

function! s:is_quickfix_window(winnr) abort
    return getbufvar(winbufnr(a:winnr), '&buftype') ==# 'quickfix'
endfunction

call s:window.register('quickfix', {'close': function('closesubwin#close_quickfix_window'), 'detect': function('s:is_quickfix_window')})

" =============== unlisted ===============

function! s:is_unlisted_window(winnr) abort
    return !getbufvar(winbufnr(a:winnr), '&buflisted')
endfunction

call s:window.register('unlisted', {'close': function('closesubwin#close_unlisted_window'), 'detect': function('s:is_unlisted_window')})


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set et:
