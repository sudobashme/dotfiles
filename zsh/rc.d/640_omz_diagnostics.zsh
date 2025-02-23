# diagnostics.zsh
#
# Diagnostic and debugging support for oh-my-zsh

# omz_diagnostic_dump()
#
# Author: Andrew Janke <andrew@apjanke.net>
#
# Usage:
#
# omz_diagnostic_dump [-v] [-V] [file]
#
# NOTE: This is a work in progress. Its interface and behavior are going to change,
# and probably in non-back-compatible ways.
#
# Outputs a bunch of information about the state and configuration of
# oh-my-zsh, zsh, and the user's system. This is intended to provide a
# bunch of context for diagnosing your own or a third party's problems, and to
# be suitable for posting to public bug reports.
#
# The output is human-readable and its format may change over time. It is not
# suitable for parsing. All the output is in one single file so it can be posted
# as a gist or bug comment on GitHub. GitHub doesn't support attaching tarballs
# or other files to bugs; otherwise, this would probably have an option to produce
# tarballs that contain copies of the config and customization files instead of
# catting them all in to one file.
#
# This is intended to be widely portable, and run anywhere that oh-my-zsh does.
# Feel free to report any portability issues as bugs.
#
# This is written in a defensive style so it still works (and can detect) cases when
# basic functionality like echo and which have been redefined. In particular, almost
# everything is invoked with "builtin" or "command", to work in the face of user
# redefinitions.
#
# OPTIONS
#
# [file]   Specifies the output file. If not given, a file in the current directory
#        is selected automatically.
#
# -v    Increase the verbosity of the dump output. May be specified multiple times.
#       Verbosity levels:
#        0 - Basic info, shell state, omz configuration, git state
#        1 - (default) Adds key binding info and configuration file contents
#        2 - Adds zcompdump file contents
#
# -V    Reduce the verbosity of the dump output. May be specified multiple times.
#
# TODO:
# * Multi-file capture
# * Add automatic gist uploading
# * Consider whether to move default output file location to TMPDIR. More robust
#     but less user friendly.
#

autoload -Uz is-at-least

function omz_diagnostic_dump() {
  emulate -L zsh

  builtin echo "Generating diagnostic dump; please be patient..."

  local thisfcn=omz_diagnostic_dump
  local -A opts
  local opt_verbose opt_noverbose opt_outfile
  local timestamp=$(date +%Y%m%d-%H%M%S)
  local outfile=${XDG_CACHE_HOME}/diagnostics/diagdump_$timestamp.txt
  builtin zparseopts -A opts -D -- "v+=opt_verbose" "V+=opt_noverbose"
  local verbose n_verbose=${#opt_verbose} n_noverbose=${#opt_noverbose}
  (( verbose = 1 + n_verbose - n_noverbose ))

  if [[ ${#*} > 0 ]]; then
    opt_outfile=$1
  fi
  if [[ ${#*} > 1 ]]; then
    builtin echo "$thisfcn: error: too many arguments" >&2
    return 1
  fi
  if [[ -n "$opt_outfile" ]]; then
    outfile="$opt_outfile"
  fi

  # Always write directly to a file so terminal escape sequences are
  # captured cleanly
  _omz_diag_dump_one_big_text &> "$outfile"
  if [[ $? != 0 ]]; then
    builtin echo "$thisfcn: error while creating diagnostic dump; see $outfile for details"
  fi

  builtin echo
  builtin echo Diagnostic dump file created at: "$outfile"
  builtin echo
  builtin echo "WARNING: This dump file contains all your zsh and omz configuration files,"
  builtin echo "so don't share it publicly if there's sensitive information in them."
  builtin echo
  ${HOME}/.local/bin/subl "$outfile" || /usr/local/bin/nvim "$outfile";
}

function _omz_diag_dump_one_big_text() {
  local program programs progfile md5

  ## Entry point of report 
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Your ZSH Diagnostic Dump
  builtin echo
  builtin echo File location: $outfile
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  # Basic system and zsh information
  builtin echo Date: $(date)
  builtin echo 
  builtin echo Kernel Name: $(uname -s)
  builtin echo
  builtin echo Kernel Release: $(uname -r)
  builtin echo
  builtin echo Node: $(uname -n)
  builtin echo
  builtin echo Machine: $(uname -m)
  builtin echo
  builtin echo Processor: $(uname -p)
  builtin echo
  builtin echo Platform: $(uname -i)
  builtin echo
  builtin echo OS: $(uname -o)
  builtin echo
  builtin echo OSTYPE: $OSTYPE
  builtin echo
  builtin echo ZSH_VERSION: $ZSH_VERSION
  builtin echo
  builtin echo User: $USERNAME
  builtin echo
  builtin echo Umask: $(umask)
  builtin echo
  _omz_diag_dump_os_specific_version
  builtin echo

  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  # Installed programs
  builtin echo Core Commands:
  builtin echo 
  programs=(sh zsh ksh bash sed cat grep ls find git df dig du env gcc ifconfig last mount mtr netstat ping ps pv stat sysctl tcpdump traceroute uptime w who )
  # local progfile="" extra_str="" sha_str=""
  for program in $programs; do
    # extra_str="" sha_str=""
    progfile=$(builtin which $program)
    if [[ $? == 0 ]]; then
      if [[ -e $progfile ]]; then
        # if builtin whence shasum &>/dev/null; then
        #   sha_str=($(command shasum $progfile))
        #   sha_str=$sha_str[1]
        #   extra_str+=" SHA $sha_str"
        # fi
        if [[ -h "$progfile" ]]; then
          extra_str+=" ( -> ${progfile:A} )"
        fi
      fi
      builtin printf '%-9s %-20s %s\n' "$program is" "$progfile" # "$extra_str"
    else
      builtin echo "$program: not found"
    fi
  done
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Command Versions:
  builtin echo
  builtin echo "zsh: $(zsh --version)"
  builtin echo "this zsh session: $ZSH_VERSION"
  builtin echo "bash: $(bash --version | command grep bash)"
  builtin echo "git: $(git --version)"
  builtin echo "grep: $(grep --version)"
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  # Core command definitions
  _omz_diag_dump_check_core_commands || return 1
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  # ZSH Process state
  builtin echo Process state:
  builtin echo 
  builtin echo pwd: $PWD
  builtin echo 
  if builtin whence pstree &>/dev/null; then
    builtin echo Process tree for this shell:
    pstree -p $$
  else
    ps -fT
  fi
  builtin echo 
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Aliases
  builtin echo 
  builtin alias 
  builtin echo 
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Environment
  builtin echo 
  #builtin set | command grep -a '^\(ZSH\|plugins\|TERM\|LC_\|LANG\|precmd\|chpwd\|preexec\|FPATH\|TTY\|DISPLAY\|PATH\)\|OMZ'
  command env
  builtin echo
  #TODO: Should this include `env` instead of or in addition to `export`?
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Exported:
  builtin echo 
  builtin echo $(builtin export | command sed 's/=.*//')
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Locale:
  builtin echo 
  command locale
  builtin echo

  # Zsh installation and configuration
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Zsh configuration:
  builtin echo
  builtin echo Setopt: 
  builtin echo 
  builtin setopt
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Zstyle: 
  builtin echo
  builtin zstyle
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Functions
  builtin echo
  builtin print -l ${(okv)functions}
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo Fpath Directories:
  builtin echo
  command ls -lad $fpath
  builtin echo 
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo ZSH Installation:
  builtin echo
  command ls -ld ${ZDOTDIR}
  builtin echo
  command ls -ld ${DOTFILES}
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo DOTFILES Git State:
  builtin echo 
  (builtin cd $DOTFILES && builtin echo "HEAD: $(git rev-parse HEAD)" && git remote -v && git status | command grep "[^[:space:]]")
  if [[ $verbose -ge 1 ]]; then
    (builtin cd $DOTFILES && git reflog --date=default | command grep pull)
  fi
  builtin echo 
  # Key binding and terminal info
  if [[ $verbose -ge 1 ]]; then
    builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    builtin echo "bindkey:"
    builtin echo 
    builtin bindkey
    builtin echo
    builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    builtin echo "infocmp:"
    builtin echo
    command infocmp -L
    builtin echo
  fi

  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  # Configuration file info
  local zdotdir=${ZDOTDIR:-$HOME}
  builtin echo "Zsh Configuration Files:"
  builtin echo 
  local cfgfile cfgfiles
  # Some files for bash that zsh does not use are intentionally included
  # to help with diagnosing behavior differences between bash and zsh
  cfgfiles=( \
    /etc/profile \
    /etc/zprofile \
    /etc/zshrc \
    $zdotdir/.zshenv \
    $zdotdir/.zprofile \
    $zdotdir/.zshrc \
    $zdotdir/.zlogin \
    $zdotdir/.zlogout \
    ~/.profile \
    )

  command ls -lad $cfgfiles 2>&1
  builtin echo
  if [[ $verbose -ge 1 ]]; then
    for cfgfile in $cfgfiles; do
      if [[ -f $cfgfile ]]; then
        builtin echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
        builtin echo 
        _omz_diag_dump_echo_file_w_header $cfgfile
      fi
    done
    builtin echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
  fi
  builtin echo
  builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  builtin echo "Zsh compdump files:"
  builtin echo
  local dumpfile dumpfiles
  #command ls -lad $zdotdir/.zcompdump
  dumpfile=( "${XDG_CACHE_HOME}/zsh/compdump" )
  if [[ $verbose -ge 2 ]]; then
      command ls -ld $dumpfile 
      builtin echo 
      _omz_diag_dump_echo_file_w_header $dumpfile
      builtin echo
      builtin echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  fi
}

function _omz_diag_dump_check_core_commands() {
  builtin echo "Core command check:"
  builtin echo 
  local redefined name builtins externals reserved_words
  redefined=()
  # All the zsh non-module builtin commands
  # These are taken from the zsh reference manual for 5.0.2
  # Commands from modules should not be included.
  # (For back-compatibility, if any of these are newish, they should be removed,
  # or at least made conditional on the version of the current running zsh.)
  # "history" is also excluded because OMZ is known to redefine that
  reserved_words=( do done esac then elif else fi for case if while function
    repeat time until select coproc nocorrect foreach end '!' '[[' '{' '}'
    )
  builtins=( alias autoload bg bindkey break builtin bye cd chdir command
    comparguments compcall compctl compdescribe compfiles compgroups compquote comptags
    comptry compvalues continue dirs disable disown echo echotc echoti emulate
    enable eval exec exit false fc fg functions getln getopts hash
    jobs kill let limit log logout noglob popd print printf
    pushd pushln pwd r read rehash return sched set setopt shift
    source suspend test times trap true ttyctl type ulimit umask unalias
    unfunction unhash unlimit unset unsetopt vared wait whence where which zcompile
    zle zmodload zparseopts zregexparse zstyle )
  if is-at-least 5.1; then
    reserved_word+=( declare export integer float local readonly typeset )
  else
    builtins+=( declare export integer float local readonly typeset )
  fi
  builtins_fatal=( builtin command local )
  externals=( zsh )
  for name in $reserved_words; do
    if [[ $(builtin whence -w $name) != "$name: reserved" ]]; then
      builtin echo "reserved word '$name' has been redefined"
      builtin which $name
      redefined+=$name
    fi
  done
  for name in $builtins; do
    if [[ $(builtin whence -w $name) != "$name: builtin" ]]; then
      builtin echo "builtin '$name' has been redefined"
      builtin which $name
      redefined+=$name
    fi
  done
  for name in $externals; do
    if [[ $(builtin whence -w $name) != "$name: command" ]]; then
      builtin echo "command '$name' has been redefined"
      builtin which $name
      redefined+=$name
    fi
  done

  if [[ -n "$redefined" ]]; then
    builtin echo "SOME CORE COMMANDS HAVE BEEN REDEFINED: $redefined"
  else
    builtin echo "All core commands are defined normally"
  fi

}

function _omz_diag_dump_echo_file_w_header() {
  local file=$1
  if [[ ( -f $file || -h $file ) ]]; then
    builtin echo "========== $file =========="
    if [[ -h $file ]]; then
      builtin echo "==========    ( => ${file:A} )   =========="
    fi
    command cat $file
    builtin echo 
    builtin echo "========== end $file =========="
    builtin echo
  elif [[ -d $file ]]; then
    builtin echo "File '$file' is a directory"
  elif [[ ! -e $file ]]; then
    builtin echo "File '$file' does not exist"
  else
    command ls -lad "$file"
  fi
}

function _omz_diag_dump_os_specific_version() {
  local osname osver version_file version_files
  case "$OSTYPE" in
    darwin*)
      osname=$(command sw_vers -productName)
      osver=$(command sw_vers -productVersion)
      builtin echo "OS Version: $osname $osver build $(sw_vers -buildVersion)"
      ;;
    cygwin)
      command systeminfo | command head -n 4 | command tail -n 2
      ;;
  esac

  if builtin which lsb_release >/dev/null; then
    builtin echo "OS Release: $(command lsb_release -s -d)"
  fi

  version_files=( /etc/*-release(N) /etc/*-version(N) /etc/*_version(N) )
  for version_file in $version_files; do
    builtin echo "$version_file:"
    command cat "$version_file"
    builtin echo
  done
}
