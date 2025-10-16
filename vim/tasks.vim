" ---------------------------------
" TASK MANAGEMENT

let g:tdfile = getcwd() . '/TODO.TASKS'

" Minimal helpers for simple task management in TODO.TASKS
function! OpenTodoTasks() abort
  if !filereadable(g:tdfile)
    call writefile([
          \ '# TODO: current prioritizd tasks',
          \ 'TODO:',
          \ '',
          \ '# DONE: coding completed, will be included in next commit message',
          \ 'DONE:',
          \ '',
          \ '# BACKLOG: tasks not yet prioritized for immediate work',
          \ 'BACKLOG:',
          \ ''
          \ ], g:tdfile)
  endif
  execute 'edit ' . fnameescape(g:tdfile)
  " Jump to TODO: section if found
  let lnum = search('^\s*TODO:\s*$', 'w')
  if lnum > 0
    " Move cursor two lines below CURRENT:
    call cursor(lnum + 2, 1)
  else
    normal! gg
  endif
endfunction

function! FindOrCreateSection(name) abort
  let l:pat = '^\s*' . a:name . ':\s*$'
  let lnum = search(l:pat, 'nw')
  if lnum == 0
    call append(line('$'), '')
    call append(line('$'), a:name . ':')
    let lnum = line('$')
  endif
  return lnum
endfunction

function! MoveRangeToSection(section) range abort
  let l:start = a:firstline
  let l:end   = a:lastline
  let l:lines = getline(l:start, l:end)
  execute l:start . ',' . l:end . 'delete _'
  let l:header = FindOrCreateSection(a:section)
  call append(l:header, l:lines)
endfunction

" Open TODO.TASKS in CWD; create with section headers if missing
nnoremap <silent> <leader>to :call OpenTodoTasks()<CR>

" Normal mode: current line
nnoremap <silent> <leader>tb :<C-U>call MoveRangeToSection('BACKLOG')<CR>
nnoremap <silent> <leader>tt :<C-U>call MoveRangeToSection('TODO')<CR>
nnoremap <silent> <leader>td :<C-U>call MoveRangeToSection('DONE')<CR>

" Visual mode: selected range — NOTE the '<,'> to pass the range
xnoremap <silent> <leader>tb :<C-U>'<,'>call MoveRangeToSection('BACKLOG')<CR>
xnoremap <silent> <leader>tt :<C-U>'<,'>call MoveRangeToSection('TODO')<CR>
xnoremap <silent> <leader>td :<C-U>'<,'>call MoveRangeToSection('DONE')<CR>

" Append current line or selection as a new task under NEW:
" this allows me to define a new task or set of tasks in context,
" then move with a keyboard shortcut to TODO.TASKS > NEW: with 
" backreferencing the original context
function! AddToNewTasks() range abort
  " Save current buffer info before switching
  let l:orig_buf = expand('%:.')               " path relative to cwd
  let l:orig_win = win_getid()
  let l:filepath = expand('%:p')               " absolute path
  let l:relpath  = expand('%:.')               " relative to cwd

  let l:first = a:firstline
  let l:last  = a:lastline
  let l:lines = getline(l:first, l:last)
  let l:ref   = '  —  ' . l:relpath . ':' . l:first

  " Cut (not copy) the lines from source
  execute l:first . ',' . l:last . 'delete'

  " Build formatted entries
  let l:entries = map(copy(l:lines), {_, v -> v . l:ref})

  " Open or create TODO.TASKS and insert after NEW:
  call OpenTodoTasks()
  let l:header = FindOrCreateSection('NEW')
  call append(l:header, l:entries)

  " Write silently (no 'written' message)
  silent! write

  " Minimal feedback
  echo 'added ' . len(l:entries) . ' task' . (len(l:entries) > 1 ? 's' : '') . '...'

  " Return to original buffer and window
  call win_gotoid(l:orig_win)
  execute 'edit ' . fnameescape(l:orig_buf)
endfunction

" Key mappings for normal and visual mode
nnoremap <leader>tn :call AddToNewTasks()<CR>
xnoremap <leader>tn :call AddToNewTasks()<CR>
"
"

function! FollowTaskFileBackreference() abort
  let l:line = getline('.')

  " Split on the dash — assuming the file reference is after it
  let l:parts = split(l:line, '—')  " handles both hyphen and em dash
  if len(l:parts) < 2
    echo "No backreference found on this line"
    return
  endif

  " Take the last part and trim spaces
  let l:ref = trim(l:parts[-1])

  " Split into file and line
  let [l:file, l:lnum] = split(l:ref, ':')
  let l:lnum = str2nr(l:lnum)

  if filereadable(l:file)
    execute 'edit ' . fnameescape(l:file)
    execute l:lnum
  else
    echo "File not found: " . l:file
  endif
endfunction

nnoremap <leader>tf :call FollowTaskFileBackreference()<CR>

