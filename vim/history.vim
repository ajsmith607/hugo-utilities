nnoremap <leader>hh :edit ~/Dropbox/business/code/hugo/hugo-utilities/WORKFLOW.txt<CR>

if !RequireVarsCSV('g:pagedir, g:imagedir, g:image_exts')
  finish
endif

" <leader>c: expode citation on current line
au FileType ghmarkdown map <leader>ec ddk:r ! explode-cite.sh<CR>

" <F2>: execute a bash script compile-assets.sh assumed to be in user PATH, 
"       (undergo/scripts/compile-assets.sh a wrapper of compile-assets.py in the same directory) 
"       then read file stored in the shell PWD into buffer cursor location, 
"       then write buffer
nnoremap <silent> <F2> :execute '! (cd ' . getcwd() . ' && compile-assets.sh)' <Bar> execute 'read ' . fnameescape(getcwd() . '/figstoadd.txt') <Bar> write<CR>

" <leader>mo: open *.md file indicated by the path under the cursor (such as those in fig shortcodes) 
augroup GHMarkdownOpen
  autocmd!
  autocmd FileType ghmarkdown execute 'setlocal path+=' . fnameescape(getcwd() . '/content/**')
  autocmd FileType ghmarkdown setlocal suffixesadd+=.md
  autocmd FileType ghmarkdown nnoremap <buffer> <leader>mo :execute 'find ' . expand('<cfile>')<CR>
augroup END

function! FindImage(base)
  for l:ext in g:image_exts
    let l:cand = a:base . '.' . l:ext
    if filereadable(l:cand)
      return l:cand
    endif
  endfor
  return ''
endfunction

function! GetBasename()
  " full path to the current buffer (.md file)
  let l:bufpath = expand('%:p')
  " strip extension
  let l:base = fnamemodify(l:bufpath, ':r')
  return l:base
endfunction

function! OpenImage(viewer)
  let l:raw  = GetBasename() 
  let l:cand = FindImage(l:raw)
  if empty(l:cand)
    echohl ErrorMsg | echom 'No image found for ' . l:raw | echohl None
    return
  endif
  if a:viewer ==# 'gimp'
    call jobstart('swaymsg workspace 2; exec gimp ' . shellescape(l:cand), {'detach': v:true})
  else
    call jobstart([a:viewer,l:cand], {'detach': v:true})
  endif
endfunction

function! InsertOcrText()
  " full path to the current buffer (.md file)
  let l:bufpath = expand('%:p')
  " strip extension
  let l:base = fnamemodify(l:bufpath, ':r')

  " try extensions
  for l:ext in g:image_exts
    let l:cand = l:base . '.' . l:ext
    if filereadable(l:cand)
      let l:text = system(['ocrimage.sh', l:cand, 'stdout'])
      call append(line('.'), split(l:text, "\n"))
      "echom 'Inserted OCR from ' . l:cand
      return
    endif
  endfor

  echohl ErrorMsg | echom 'No image found for base: ' . l:base | echohl None
endfunction

augroup OpenImageMappings
  autocmd!
  " open with fim in current workspace
  autocmd FileType ghmarkdown nnoremap <buffer> <leader>iv :call OpenImage('fim')<CR>
  " open with gimp in workspace 2
  autocmd FileType ghmarkdown nnoremap <buffer> <leader>ie :call OpenImage('gimp')<CR>
  " insert OCR text under cursor line
  autocmd FileType ghmarkdown nnoremap <buffer> <leader>it :call InsertOcrText()<CR>
augroup END

" support for pagelink shortcode    
" <leader>ps : insert the shortcode boilerplate/skeleton (auto calls pf)
" <leader>pf : type-ahead search and insert the basename of the desired page
"              file
"
" Inserts the boilerplate and positions cursor before basename
function! InsertPagelinkSkeleton()
  " Insert the boilerplate
  call nvim_put(['{{< pagelink "" "" >}}'], 'c', v:true, v:true)
  " Move cursor to the start of the line
  normal! 0
  " Search forward for the first "" and land on the first quote
  call search('""', 'c')
  call InsertPageBasename(g:pagedir)
  " Move cursor one char to the right, inside the next set of quotes
endfunction

nnoremap <leader>ps :call InsertPagelinkSkeleton()<CR>

" support for fig shortcode    
" <leader>fs : insert the shortcode boilerplate/skeleton (auto calls ff)
" <leader>ff : type-ahead search and insert the basename of the desired
"              metadata file
"
" Inserts the boilerplate and positions cursor before basename
function! InsertFigSkeleton()
  " Insert the boilerplate
  call nvim_put(['{{< fig "" "800" />}}'], 'c', v:true, v:true)
  " Move cursor to the start of the line
  normal! 0
  " Search forward for the first "" and land on the first quote
  call search('""', 'c')
  call InsertPageBasename(g:imagedir, v:false)
  " Move cursor one char to the right, inside the quotes
  "normal! l
endfunction

nnoremap <leader>fs :call InsertFigSkeleton()<CR>

" helper functions
function! InsertPageBasename(subpath, ...) abort
  " Build full path
  let l:dir = expand(getcwd() . "/" . a:subpath)

  " Base ripgrep command
  let l:cmd = 'rg --files ' . shellescape(l:dir) . ' --glob "*.md" --glob "!**/*index*.md"'

  " Determine fullstrip (default true)
  let l:fullstrip = get(a:000, 0, v:true)

  if l:fullstrip
    " Strip directory + extension
    let l:cmd .= " | sed 's#.*/##;s/\\.md$//'"
  else
    " Strip everything up through subpath/
    let l:strip = substitute(l:dir, '/', '\\/', 'g')
    let l:cmd .= " | sed 's#" . l:strip . "/##;s/\\.md$//'"
  endif

  call fzf#run(fzf#wrap({
        \ 'source': l:cmd,
        \ 'sink*': { lines -> InsertAtCursor(lines) },
        \ }))
endfunction

function! InsertAtCursor(lines)
  if len(a:lines) > 0
    let l:word = a:lines[0]
    " Insert exactly at cursor position
    call nvim_put([l:word], 'c', v:true, v:true)
    " Now drop into insert mode AFTER insertion
    call feedkeys('2la', 'n')
  endif
endfunction

" Map it
nnoremap <leader>pf :call InsertPageBasename(g:pagedir)<CR>
nnoremap <leader>ff :call InsertPageBasename(g:imagedir, v:false)<CR>

" Insert boilerplate for figure and citation caption 
function! InsertFigureBoilerplate()
  call append(line('.'), [
       \ '<figure>',
       \ ' ',
       \ '> ',
       \ ' ',
       \ '  <figcaption>',
       \ '  <cite>',
       \ ' ',
       \ '  — .',
       \ ' ',
       \ '  </cite>',
       \ ' ',
       \ '  </figcaption>',
       \ '  <aside> ',
       \ ' ',
       \ '  — .',
       \ ' ',
       \ '  </aside> ',
       \ '</figure>',
       \ ])
  " Move cursor to '> ' line (3rd line after current line)
  " and place it just after '> '
  call cursor(line('.') + 3, 3)
endfunction

nnoremap <leader>fp :call InsertFigureBoilerplate()<CR>

