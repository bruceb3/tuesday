# Tuesday

WIP - completely experiemental. Would this even be a useful plugin to have?

# Background

ctrl-o and ctrl-i move the cursor back and forth between jump points in files.

Tuesday aims to provide the same feature except to track the entire of state of vim, at least as much as is stored in via the mksession commands.

## Implementation

### Saving session

The session is saved under the directory ~/.tuesday

Each session file is given the name "project"-date-n

The project is the name of the directory at the end of the path of the current directory, e.g. If current working directory is /Users/fred/code/do-amazing, the project will be do-amazing.

The date is stored in the file name but is not used by Tuesday. Instead the modification time of the file is used.

### Default key mappings

,s to save a session
,b to move back a session
,f to move forward a session

### Using auto commands to automatically save sessions

As a suggestion, the following code in your ~/.vimrc will cause a session to be save whenever a file is opened.

```vim
augroup tuesday
  au!
  au BufWritePre,BufRead * :call TuesdaySave()
end
```

# Customisation

## sessionoptions

Tuesday doesn't change the vim's sessionoptions. This is left as exercise for the user.

## Removing session file while vim is running.

Tuesday keeps track of the number of sessions available. If you wish to remove some sessions and have Tuesday reload, call the function :TuesdayReload()
