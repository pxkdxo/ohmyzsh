# zshoptions.plugin.zsh: Configure preferred options for an interactive shell

# If this is not an interactive shell, abort.
case "$-" in
 (*i*) ;;
 (*) return ;;
esac

#########################
# Changing Directories
#########################
setopt autocd
setopt autopushd
setopt cdablevars
setopt chaselinks
setopt pushdignoredups
setopt pushdtohome

#########################
# Completion
#########################
setopt alwaystoend  # move cursor to the end of accpeted completions
setopt autonamedirs  # alias directories by variables
# setopt completealiases  # completion instead of expansion
setopt completeinword  # middle-out completion
setopt globcomplete  # glob pattern completion
setopt nolistbeep  # NO BEEPING
# setopt menucomplete  # *overrides* 'automenu'
setopt recexact  # auto-accept exact matches

#########################
# Expansion and Globbing
#########################
setopt braceccl  # expand sequence expressions in braces
setopt extendedglob  # patterns include ‘#', ‘~' and ‘^'
setopt globassign  # assign matches to variables ... why not
setopt globstarshort  # **/*,***/* => **,***
setopt histsubstpattern  # modifiers ':s' and ':&' use pattern matching
# setopt nullglob  # *overrides* 'nomatch'
setopt rcexpandparam  # x${a}y => x${a[1]}y x${a[2]}y ... x${a[-1]}y
setopt rematchpcre  # match PCRE patterns with the '=~' operator
setopt warnnestedvar  # Nice to be notified

#########################
# History
#########################
setopt histallowclobber  # add '|' to output redirections in history
setopt nohistbeep  # NO. BEEPING.
setopt histexpiredupsfirst
setopt histfcntllock
setopt histfindnodups
# setopt histignorealldups
setopt histignoredups
setopt histignorespace
setopt histlexwords
setopt histnostore
setopt histreduceblanks
setopt histsavenodups
setopt histverify
setopt incappendhistory  # write commands to histfile on execution
# setopt sharehistory  # 'incappendhistory' and continuous import

#########################
# Input/Output
#########################
setopt noclobber
setopt correct
setopt interactivecomments
setopt rmstarsilent  # Living dangerously

#########################
# Shell Emulation
#########################
setopt appendcreate
# setopt posixbuiltins

#########################
# ZLE
#########################
setopt nobeep
setopt combiningchars

#########################
# Job Control
#########################
setopt autocontinue
setopt longlistjobs

#########################
# Prompting
#########################
setopt promptsubst

#########################
# Scripts and Functions
#########################
setopt cbases
setopt nomultifuncdef

# vi: set ft=zsh et sts=2 sw=2
