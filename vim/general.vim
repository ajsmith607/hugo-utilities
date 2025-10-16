function! RequireVarsCSV(list) abort
  for var in split(a:list, '\s*,\s*')
    if !exists(var)
      echohl WarningMsg
      echom '[config] Missing required variable: ' . var . ' in init.vim' 
      echohl None
      return 0
    endif
  endfor
  return 1
endfunction
