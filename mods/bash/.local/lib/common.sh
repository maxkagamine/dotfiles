# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash disable=SC2120

throw() {
  printf '%s: %s\n' "${0##*/}" "$1" >&2
  return 1
}

# Usage: parse_args (<option descriptor> [<callback>])... -- <args>
#
# Parses GNU-style options. Supports short and long options, combined/bundled
# short options, options with values (in any format: --foo value, -f value,
# --foo=value, or -fvalue), repeated options (by using a callback), option
# aliases, and the '--' to stop option processing. A single dash is treated as
# a positional parameter.
#
# The option descriptor is a comma-separated list of option aliases (i.e. any
# short and long names for the same option, with leading dashes) optionally
# followed by an '=' to indicate an option that takes a value.
#
# An option descriptor may optionally be followed by a callback which is eval'd
# when the option is encountered. For options that take a value, {} will be
# replaced with the shell-escaped value. Compared to the OPTS array described
# below, using callbacks simplifies assigning values to named variables and
# makes it possible to override an option set earlier (e.g. in a shell alias)
# and to have repeatable options (like -vvv, or --bar in the below example).
#
# If a --help option is defined and a function called 'help' exists, the
# callback defaults to 'help'.
#
# The following variables will hold the result of argument parsing:
#
#   OPTS    Associative array mapping each option name (every alias, regardless
#           of which was actually used, with leading dashes omitted) to the
#           provided value, or 1 in the case of flags.
#
#   REST    Indexed array containing all positional parameters.
#
# When used in a function, these should be declared as local variables first.
#
# Example:
#
#   foo=$DEFAULT_FOO
#   bar=()
#   dry_run=
#   verbose=
#
#   parse_args \
#     -f,--foo= 'foo={}' \
#     --bar= 'bar+=({})' \
#     --dry-run 'dry_run=1; verbose=1' \
#     -v,--verbose 'verbose=1' \
#     -h,--help \
#     -- "$@"
#
parse_args() {
  # Prefixed with underscores to avoid shadowing script vars since callbacks are
  # eval'd in the function scope
  declare -A __aliases
  declare -A __callbacks
  declare -A __flags
  declare -A __params
  local __arg
  local __callback
  local __descriptor
  local __is_short
  local __name
  local __names
  local __option
  local __type
  local __value

  # Parse option descriptors as comma-separated short or long options, with a
  # trailing equals sign indicating options that take a value
  while (( $# > 0 )); do
    __descriptor=$1
    shift

    if [[ $__descriptor == '--' ]]; then
      break
    fi

    # The option descriptor may optionally be followed by a callback to be
    # eval'd upon encountering the option. This can simplify assigning values to
    # named variables and makes it possible to override an option previously
    # given, e.g. in the case of aliases.
    if [[ $# != 0 && $1 != -* ]]; then
      __callback=$1
      shift

      # Validate callback
      if [[ $__callback == *'{}'* && $__descriptor != *= ]]; then
        throw "${FUNCNAME[0]}: callback expects a value but the option is a flag (add '=' to the end of '$__descriptor' or replace '{}' with '1')"
      fi
    else
      __callback=
    fi

    IFS=, read -ra __names <<<"${__descriptor%=}"
    for __name in "${__names[@]}"; do
      # Validate option descriptor
      if [[ $__name != -* ]]; then
        throw "${FUNCNAME[0]}: option must begin with a dash (in '$__descriptor')"
      elif [[ $__name == ---* ]]; then
        throw "${FUNCNAME[0]}: too many leading dashes (in '$__descriptor')"
      elif [[ $__name == *=* ]]; then
        throw "${FUNCNAME[0]}: '=' should only appear at the end (in '$__descriptor')"
      elif [[ $__name == *[[:space:]]* ]]; then
        throw "${FUNCNAME[0]}: option name must not contain whitespace (in '$__descriptor')"
      elif [[ $__name == -[^-]?* ]]; then
        throw "${FUNCNAME[0]}: short options can only be a single character (in '$__descriptor')"
      fi

      # Create a map of aliases so that we can access an option from OPTS using
      # any of its names, regardless of which was actually used
      __aliases[$__name]=${__names[*]}

      # Using associative arrays as hashsets to simplify checking the option
      # type below, since bash doesn't have a proper "indexOf"
      if [[ $__descriptor == *= ]]; then
        __params[$__name]=1
      else
        __flags[$__name]=1
      fi

      # Map each alias to the callback
      if [[ $__callback ]]; then
        __callbacks[$__name]=$__callback
      fi
    done
  done

  # OPTS will hold all of the passed options (and all of their aliases), leading
  # dashes omitted, mapped to their values (or 1 if a flag), while REST will
  # hold all positional parameters.
  declare -gA OPTS
  declare -ga REST

  # Program args following the '--' which terminates the descriptor list
  while (( $# > 0 )); do
    __arg=$1
    shift

    case $__arg in
      --)
        REST+=("$@")
        break
        ;;
      -[^-]*)
        __option=${__arg:0:2}
        __value=${__arg:2}
        __is_short=1
        ;;
      --*)
        __option=${__arg%%=*}
        __value=${__arg#*=}
        __is_short=
        ;;
      *)
        REST+=("$__arg")
        continue
        ;;
    esac

    # Determine if option is valid and if it expects a value or not
    if [[ ${__flags[$__option]} ]]; then
      __type=flag
    elif [[ ${__params[$__option]} ]]; then
      __type=param
    else
      throw "unknown option: $__option"
    fi

    # Process the option
    if [[ $__type == 'flag' ]]; then
      if [[ $__is_short && $__value ]]; then
        # In this case, the "value" will be other options, so put them back
        set -- "-$__value" "$@"
      elif [[ $__arg == *=* ]]; then
        throw "$__option does not take a value"
      fi
      __value=1
    elif [[ ($__is_short && ! $__value) || (! $__is_short && $__arg != *=*) ]]; then
      # Value should be the following arg
      if (( $# == 0 )); then
        throw "$__option expects a value"
      fi
      __value=$1
      shift
    fi

    # Run the callback if there is one. {} will be replaced with the escaped
    # value, similar to find/fd etc. ($__value is also in scope, but shellcheck
    # will complain if we use a variable in a single-quoted string, and this way
    # looks cleaner anyway)
    if [[ ${__callbacks[$__option]} ]]; then
      eval "${__callbacks[$__option]//\{\}/$(printf '%q' "$__value")}"
    fi

    # shellcheck disable=SC2034 # OPTS appears unused
    for __name in ${__aliases[$__option]}; do
      __name=${__name#-}
      __name=${__name#-}
      OPTS[$__name]=$__value

      # Call help() automatically if --help or any of its aliases are given
      # (this is done here at the end rather than when $callback is set since at
      # that point we haven't yet parsed the option names out of the descriptor)
      if [[ $__name == 'help' && ! ${__callbacks[$__option]} ]] && declare -F help >/dev/null; then
        help
      fi
    done
  done
}

# Usage: expand_directories [-r|--recursive] [--glob <glob>] [--var <var>]
#                           [--default <path>] [--required]
#                           [--paths-from-stdin] [[--] <paths>]
#
# Reads paths and replaces directories with their containing files while
# passing along file paths as-is.
#
# Options:
#
#   -r, --recursive      Expand directories recursively.
#   --glob <glob>        Filter directory contents to files matching the glob.
#                        Non-directory paths in the input are unaffected. The
#                        pattern is case-insensitive unless it contains an
#                        uppercase character (default fd behavior).
#   --var <var>          Store result in <var> as an array instead of echoing
#                        to stdout.
#   --default <path>     If <paths> is empty (and stdin is as well, if
#                        --paths-from-stdin is used), uses <path> instead.
#   --required           If the result is empty, throws 'no files to process'.
#   --paths-from-stdin   Reads paths from stdin (in addition to <paths>).
#
expand_directories() {
  declare -A OPTS
  declare -a REST
  parse_args \
    -r,--recursive \
    --glob= \
    --var= \
    --default= \
    --required \
    --paths-from-stdin \
    -- "$@"

  # Prepare fd command
  local fd_opts=(--unrestricted --type file)
  if [[ ! ${OPTS[recursive]} ]]; then
    fd_opts+=(--max-depth 1)
  fi
  if [[ ${OPTS[glob]} ]]; then
    fd_opts+=(--glob "${OPTS[glob]}")
  else
    fd_opts+=(.) # regex
  fi

  # Final step of the pipe, either read into an array or pass-through to stdout
  # shellcheck disable=SC2312 # Handled by wait $! (bash 4.4+)
  if [[ ${OPTS[var]} ]]; then
    readarray -t "${OPTS[var]}"
  else
    cat
  fi < <(
    set -eo pipefail
    {
      # Yield paths from positional params, stdin, and/or the default
      any=
      for path in "${REST[@]}"; do
        echo "$path"
        any=1
      done
      if [[ ${OPTS[paths-from-stdin]} ]]; then
        while read -r path; do
          echo "$path"
          any=1
        done
      fi
      if [[ ! $any && ${OPTS[default]} ]]; then
        echo "${OPTS[default]}"
      fi
    } | {
      # Expand directories
      while read -r path; do
        if [[ -d "$path" ]]; then
          fd "${fd_opts[@]}" "$path"
        else
          echo "$path"
        fi
      done
    } | {
      # Check if anything was output
      any=
      while read -r path; do
        echo "$path"
        any=1
      done
      if [[ ! $any && ${OPTS[required]} ]]; then
        throw 'no files to process'
      fi
    }
  )
  wait $! # Result of the process substitution
}
