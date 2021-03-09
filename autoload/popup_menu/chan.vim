scriptencoding utf-8

let s:chans = {}
let s:chans_id = 1

function! s:create_chan_id()
	let s:chans_id += 1
	return s:chans_id
endfunction

function! popup_menu#chan#create(opts)
	let l:chan_id = s:create_chan_id()
	let s:chans[l:chan_id] = {
				\ 'on_data': a:opts.on_data,
				\ }
	return l:chan_id
endfunction

function! popup_menu#chan#close(chan_id)
	if has_key(s:chans, a:chan_id)
		call remove(s:chans, a:chan_id)
	endif
endfunction

function! popup_menu#chan#send_msg(chan_id, msg)
	if has_key(s:chans, a:chan_id)
		let l:chan = s:chans[a:chan_id]
		let F = l:chan.on_data
		call popup_menu#chan#close(a:chan_id)
		call F(a:chan_id, [a:msg], 'data')
	endif
endfunction


