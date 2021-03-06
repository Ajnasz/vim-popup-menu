scriptencoding utf-8

func s:noop()
endfunc

function! s:max_word_length(choices) abort
	return max(map(copy(a:choices), {_, v -> strlen(v)}))
endfunction

function! popup_menu#win_select_item_chan(item, chan, winid)
	call nvim_win_close(a:winid, 1)
	call popup_menu#chan#send_msg(a:chan, a:item)
	call popup_menu#chan#close(a:chan)
endfunction

function! s:create_keymap(winid, chan)
	if a:winid == 0
		return
	endif
	let curr = win_getid()
	let m = mode()
	if m ==# 'n' || m ==# 'i' || m ==# 'ic'
		noa call win_gotoid(a:winid)
		exe 'nnoremap <silent><expr><nowait><buffer> <cr> ":call popup_menu#win_select_item_chan(getline(''.''), ' . a:chan . ', ' . a:winid . ')\<cr>\<esc>"'
		exe 'nnoremap <silent><expr><nowait><buffer> <esc> ":call nvim_win_close(' . a:winid . ', 1)\<cr>\<esc>"'
		noa call win_gotoid(curr)
	endif
endfunction

function! popup_menu#open(choices, callback)
	let l:buf_id = nvim_create_buf(v:false, v:true)
	call nvim_buf_set_option(l:buf_id, 'buftype', 'nofile')
	call nvim_buf_set_option(l:buf_id, 'bufhidden', 'wipe')

	let l:popup_win_id = nvim_open_win(l:buf_id, v:true, {
				\ 'relative': 'cursor',
				\ 'width': s:max_word_length(a:choices),
				\ 'height': len(a:choices),
				\ 'col': 0,
				\ 'row': 1,
				\ 'border': 'double'
				\ })
	call nvim_buf_set_lines(l:buf_id, 0, -1, v:true, a:choices)

	call setwinvar(l:popup_win_id, '&number', 0)
	call setwinvar(l:popup_win_id, '&winhl', 'Normal:Pmenu,CursorLine:PmenuSel')
	call setwinvar(l:popup_win_id, '&readonly', 1)
	call setwinvar(l:popup_win_id, '&modifiable', 0)
	let chan = popup_menu#chan#create({ 'on_data': { id, data, event -> data == [''] ? s:noop() : a:callback(data[0]) } })
	call s:create_keymap(l:popup_win_id, chan)
endfunction
