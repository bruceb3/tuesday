
" Vim plugin save sessions and the traverse fowards and backwards through the
" saved sessions.
" Maintainer:   Bruce Woodward <bruce.woodward@gmail.com>
" License:      Public domain
"

let s:current_state = {}
let s:return_message = ''

fu! s:make_session_filename(dirname, suffix, count)
  return printf("%s/%s-%s-%d", a:dirname, a:suffix, strftime("%Y%m%d%H%M%S"), a:count)
endf

fu! s:make_tuesday_dir(dirname)
endf

fu! s:find_unique_session_name(savedir, projectname)
  let l:count = 1
  let l:session_filename =  s:make_session_filename(a:savedir, a:projectname, l:count)
  while !empty(glob(l:session_filename))
    let l:count = l:count + 1
    let l:session_filename = s:make_session_filename(a:savedir, a:projectname, l:count)
  endwhile
  return l:session_filename
endf

fu! s:make_project_name()
  return fnamemodify(getcwd(), ':t')
endf

fu! s:savedir()
  return expand("~/.tuesday")
endf

fu! s:setup_save_dir()
  let l:savedir = s:savedir()
  if empty(glob(l:savedir))
    call mkdir(l:savedir, "p", 0700) " assuming that this won't fail
  endif
  return l:savedir
endf

" called by s:save to move the index to the new bottom.
" side effect; after saving s:current_state[projectname] is defined.
fu! s:update_index(projectname)
  let sessions = s:ordered_sessions()
  let s:current_state[a:projectname] = len(sessions) - 1
endf

fu! s:get_index(projectname)
  if has_key(s:current_state, projectname)
    return s:current_state[projectname]
  else
    return (s:current_state[projectname] = -1)
  endif
endf

fu! s:increment_index(projectname)
  if has_key(s:current_state, projectname)
    let s:current_state[projectname] = s:current_state[projectname] + 1
  endif
endf

fu! s:reload_sessions()
  let sessions = s:make_list_of_sessions_for_this_project()
endf

fu! s:check_for_savedir()
  let savedir = s:savedir()
  if empty(glob(savedir))
    return 0
  else
    return 1
  endif
endf

fu! s:make_list_of_sessions_for_this_project()
  let savedir = s:savedir()
  let projectname = s:make_project_name()
  return glob(savedir . '/' . projectname . "*", 0, 1)
endf

fu! s:sort_by_mod_time(a, b)
  if a:a[0] < a:b[0]
    return -1
  elseif a:a[0] == a:b[0]
    return 0
  else
    return 1
  endif
endf

fu! s:ordered_sessions()
  let times = []
  let sessions = s:make_list_of_sessions_for_this_project()
  for session in sessions
    call add(times, [ getftime(session), session ])
  endfor
  call sort(sessions, "s:sort_by_mod_time")
  return sessions
endf

fu! s:go_back_one_session(projectname)
  let sessions = s:ordered_sessions()
  if len(sessions) == 0 " no sessions found.
    let s:return_message .= " No sessions found."
    return -1
  endif
  if !has_key(s:current_state, a:projectname)
    let s:current_state[a:projectname] = len(sessions) - 1
  else
    if s:current_state[a:projectname] == 0
      let s:return_message .= " At the top of the list."
      return -1
    else
      let s:current_state[a:projectname] = s:current_state[a:projectname] - 1
    endif
  endif
  let restore_session = sessions[s:current_state[a:projectname]]
  let s:return_message .= printf(" At session %d of %d", s:current_state[a:projectname]+1, len(sessions))
  return restore_session
endf

fu! s:go_forward_one_session(projectname)
  let sessions = s:ordered_sessions()
  if len(sessions) == 0 " no sessions found.
    let s:return_message .= " No sessions found."
    return -1
  endif
  if !has_key(s:current_state, a:projectname)
    let s:current_state[a:projectname] = len(sessions) - 1
  end
  if s:current_state[a:projectname] == len(sessions) - 1
    let s:return_message .= " At the bottom of the list."
    return -1
  else
    let s:current_state[a:projectname] = s:current_state[a:projectname] + 1
  endif
  let restore_session = sessions[s:current_state[a:projectname]]
  let s:return_message .= printf(" At session %d of %d", s:current_state[a:projectname]+1, len(sessions))
  return restore_session
endf

fu! s:Save()
  let s:return_message = 'Saving session'
  let savedir = s:setup_save_dir()
  let projectname = s:make_project_name()
  let session_filename = s:find_unique_session_name(savedir, projectname)
  exe "mksession! " . l:session_filename
  call s:update_index(projectname)
  echo s:return_message
endf

fu! s:Back()
  let s:return_message = 'Back a session'
  let projectname = s:make_project_name()
  if !s:check_for_savedir()
    return 0
  endif
  let restore_session = s:go_back_one_session(projectname)
  if restore_session != -1
    exe "so " . restore_session
  endif
  echo s:return_message
endf

fu! s:Forward()
  let s:return_message = 'Forward a session'
  let projectname = s:make_project_name()
  if !s:check_for_savedir()
    return 0
  endif
  let restore_session = s:go_forward_one_session(projectname)
  if restore_session != -1
    exe "so " . restore_session
  endif
  echo s:return_message
endf

fu! s:Reload()
  let projectname = s:make_project_name()
  if has_key(s:current_state, projectname)
    remove(s:current_state, projectname)
  endif
endf

nmap <silent> <Char-040>s :call <SID>Save()<cr>
nmap <silent> <Char-040>f :call <SID>Forward()<cr>
nmap <silent> <Char-040>b :call <SID>Back()<cr>

command! -nargs=0 TuesdayReload call s:Reload()
