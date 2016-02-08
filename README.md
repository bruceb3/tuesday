# Tuesday

WIP - completely experiemental. Would this be a useful plugin to have?

# Background

ctrl-o and ctrl-i move the cursor back and forth between jump points in files.

Tuesday aims to provide the same feature except to track the entire of state of vim, at least as much as is stored in via the mksession and session commands.

## Implementation

### Use of sessions

Before loading a new file, a session is saved.
Before completing a split of window, a session is saved.
Before exiting vim, a session is saved.
Before creating or deleteing a tab, a session is saved.

### Saving session

Obviously place is a dot directory in the users home directory.

To name the session file, the simplest way would be a the date that the session was created with a prefix (prehaps) to communicate that the session has been created automatically.

# Customisation

## sessionoptions

Don't change the value of vim's sessionoptions. It's up the user to customise this setting. Let's just assume that reading the doco for the sessionoptions it's an unresponsible expectation.
