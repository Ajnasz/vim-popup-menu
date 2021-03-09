scriptencoding utf-8

function! s:max_word_length(choices) abort
	return max(map(copy(a:choices), {_, v -> strlen(v)}))
endfunction

function! popup_menu#popup_close(winid)
	call nvim_win_close(a:winid, 1)
endfunction

function! popup_menu#win_select_item_chan(item, chan, winid)
	call popup_menu#popup_close(a:winid)
	call chansend(a:chan, a:item)
endfunction

function! s:create_keymap(winid, chan)
	if a:winid == 0
		return
	endif
	let curr = win_getid()
	" nvim should support win_execute so we don't break visual mode.
	let m = mode()
	if m ==# 'n' || m ==# 'i' || m ==# 'ic'
		noa call win_gotoid(a:winid)
		exe 'nnoremap <silent><expr><nowait><buffer> <cr> ":call popup_menu#win_select_item_chan(getline(''.''), ' . a:chan . ', ' . a:winid . ')\<cr>\<esc>"'
		exe 'nnoremap <silent><expr><nowait><buffer> <esc> ":call popup_menu#popup_close(' . a:winid . ')\<cr>\<esc>"'
		noa call win_gotoid(curr)
	endif
endfunction

function! popup_menu#open(choices, callback)
	let l:buf_id = nvim_create_buf(v:false, v:true)
	call nvim_buf_set_option(l:buf_id, 'buftype', 'nofile')

	let l:popup_win_id = nvim_open_win(l:buf_id, v:true, {
				\ 'relative': 'cursor',
				\ 'width': s:max_word_length(a:choices),
				\ 'height': len(a:choices),
				\ 'col': 0,
				\ 'row': 1,
				\ })
	call nvim_buf_set_lines(l:buf_id, 0, -1, v:true, a:choices)

	call setwinvar(l:popup_win_id, '&number', 0)
	call setwinvar(l:popup_win_id, '&winhl', 'Normal:Pmenu,CursorLine:PmenuSel')
	call setwinvar(l:popup_win_id, '&readonly', 1)
	call setwinvar(l:popup_win_id, '&modifiable', 0)
	let chan = jobstart(['cat'], { 'on_stdout': { id, data, event -> a:callback(data[0]) } })
	call s:create_keymap(l:popup_win_id, chan)
endfunction
