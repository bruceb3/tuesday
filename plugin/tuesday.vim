
" Vim plugin save sessions and the traverse fowards and backwards through the
" saved sessions.
" Maintainer:   Bruce Woodward <bruce.woodward@gmail.com>
" License:      Public domain
"

let s:current_state = {}

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
  return fnamemodify(expand(getcwd()), ':t')
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

fu! s:save()
  let savedir = s:setup_save_dir()
  let projectname = s:make_project_name()
  let session_filename = s:find_unique_session_name(savedir, projectname)
  exe "mksession! " . l:session_filename
  s:current_state[projectname] = -1 " reset position.
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

fu! s:back()
  let projectname = s:make_project_name()
  if !s:check_for_savedir()
    return 0
  endif
  sessions = s:ordered_sessions()
  if len(sessions) == 0
    return 0
  endif
  if s:current_state[projectname] == -1
    " never gone back to previous session
    let s:current_state[projectname] == len(sessions)
    restore_session = sessions[-1]
  else
    " at the top of the list of sessions; reset to the bottom
    " TODO beep or something to let the user know.
    if s:current_state[projectname] == 1
      return 0
    endif
    let s:current_state[projectname] = s:current_state[projectname] - 1
    restore_session = sessions[s:current_state[projectname]]
  endif
  exe "so " . last_session
endf

fu! s:forward()
  echo "foo"
endf

nmap ,s :call <SID>save()<cr>
nmap ,f :call <SID>forward()<cr>
nmap ,b :call <SID>back()<cr>

