" A simple wiki plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! wiki#link#ref_single#matcher() abort " {{{1
  return extend(
        \ wiki#link#_template#matcher(),
        \ deepcopy(s:matcher))
endfunction

" }}}1


let s:matcher = {
      \ 'type': 'ref',
      \ 'rx': wiki#rx#link_ref_single,
      \ 'rx_target': '\[\zs' . wiki#rx#reftarget . '\ze\]',
      \}

function! s:matcher.parse(link) abort dict " {{{1
  let a:link.id = matchstr(a:link.full, self.rx_target)

  " Locate target url
  let a:link.lnum_target = searchpos('^\[' . a:link.id . '\]: ', 'nW')[0]
  if a:link.lnum_target == 0
    function! a:link.toggle(_url, _text) abort dict
      call wiki#log#warn(
            \ 'Could not locate reference ',
            \ ['ModeMsg', self.url]
            \)
    endfunction
    return a:link
  endif

  let a:link.url = matchstr(getline(a:link.lnum_target), g:wiki#rx#url)
  if !empty(a:link.url) | return wiki#url#extend(a:link) | endif

  " The url is not recognized, so we fall back to a link to the reference
  " position.
  function! a:link.open(...) abort dict
    normal! m'
    call cursor(self.lnum_target, 1)
  endfunction

  return a:link
endfunction

" }}}1
function! s:matcher.toggle(_url, _text) dict abort " {{{1
  return wiki#link#md#template(self.url, self.id)
endfunction

" }}}1
