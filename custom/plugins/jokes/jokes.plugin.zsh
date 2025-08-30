#!/usr/bin/env zsh
#
# Upon login, fetch a random joke from and display it

"${0:h}/jokes.py" --sleep 1 --timeout 0.1 | lolcat
