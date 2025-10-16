function! IsRealFile() abort
  if &buftype !=# '' | return 0 | endif
  let l:name = expand('%:p')
  if empty(l:name) | return 0 | endif
  return filereadable(l:name) || !empty(glob(l:name))
endfunction

function! SaveLastPos() abort
  if !IsRealFile() | return | endif
  let l:name = expand('%:p')
  let l:pos  = getpos('.')
  call writefile([l:name, string(l:pos[1]), string(l:pos[2])], getcwd().'/.nvim-last')
endfunction

function! RestoreLastPos() abort
  if argc() != 0 | return | endif
  let l:file = getcwd().'/.nvim-last'
  if !filereadable(l:file) | return | endif
  let l:data = readfile(l:file)
  if len(l:data) < 3 | return | endif
  let l:path = l:data[0]
  if empty(l:path) || !filereadable(l:path) && empty(glob(l:path)) | return | endif
  execute 'edit ' . fnameescape(l:path)
  call cursor(str2nr(l:data[1]), str2nr(l:data[2]))
  normal! zv
endfunction

augroup project_lastpos
  autocmd!
  autocmd VimEnter * call timer_start(0, {-> execute('call RestoreLastPos()')})
  autocmd BufEnter,InsertLeave,FocusLost,VimLeavePre * call SaveLastPos()
augroup END

