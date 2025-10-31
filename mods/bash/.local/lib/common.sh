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
# when the option is encountered. '{}' will be replaced with '$value' which
# holds the option value (quoting rules for variables apply). This simplifies
# assigning values to named variables and makes it possible to override an
# option previously given (e.g. in a shell alias) and have repeatable options.
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
#     --bar= 'bar+=("{}")' \
#     --dry-run 'dry_run=1; verbose=1' \
#     -v,--verbose 'verbose=1' \
#     -h,--help \
#     -- "$@"
#
parse_args() {
  declare -A flags
  declare -A params
  declare -A aliases
  declare -A callbacks
  local descriptor
  local callback
  local arg
  local option
  local value
  local is_short
  local type
  local x

  # Parse option descriptors as comma-separated short or long options, with a
  # trailing equals sign indicating options that take a value
  while (( $# > 0 )); do
    descriptor=$1
    shift

    if [[ $descriptor == '--' ]]; then
      break
    fi

    # The option descriptor may optionally be followed by a callback to be
    # eval'd upon encountering the option. This can simplify assigning values to
    # named variables and makes it possible to override an option previously
    # given, e.g. in the case of aliases.
    if [[ $# != 0 && $1 != -* ]]; then
      callback=$1
      shift
    else
      callback=
    fi

    IFS=, read -ra names <<<"${descriptor%=}"
    for x in "${names[@]}"; do
      # Validate option descriptor
      if [[ $x != -* ]]; then
        throw "${FUNCNAME[0]}: option must begin with a dash (in '$descriptor')"
      elif [[ $x == ---* ]]; then
        throw "${FUNCNAME[0]}: too many leading dashes (in '$descriptor')"
      elif [[ $x == *=* ]]; then
        throw "${FUNCNAME[0]}: '=' should only appear at the end (in '$descriptor')"
      elif [[ $x == *[[:space:]]* ]]; then
        throw "${FUNCNAME[0]}: option name must not contain whitespace (in '$descriptor')"
      elif [[ $x == -[^-]?* ]]; then
        throw "${FUNCNAME[0]}: short options can only be a single character (in '$descriptor')"
      fi

      # Create a map of aliases so that we can access an option from OPTS using
      # any of its names, regardless of which was actually used
      aliases[$x]=${names[*]}

      # Using associative arrays as hashsets to simplify checking the option
      # type below, since bash doesn't have a proper "indexOf"
      if [[ $descriptor == *= ]]; then
        params[$x]=1
      else
        flags[$x]=1
      fi

      # Map each alias to the callback
      if [[ $callback ]]; then
        callbacks[$x]=$callback
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
    arg=$1
    shift

    case $arg in
      --)
        REST+=("$@")
        break
        ;;
      -[^-]*)
        option=${arg:0:2}
        value=${arg:2}
        is_short=1
        ;;
      --*)
        option=${arg%%=*}
        value=${arg#*=}
        is_short=
        ;;
      *)
        REST+=("$arg")
        continue
        ;;
    esac

    # Determine if option is valid and if it expects a value or not
    if [[ ${flags[$option]} ]]; then
      type=flag
    elif [[ ${params[$option]} ]]; then
      type=param
    else
      throw "unknown option: $option"
    fi

    # Process the option
    if [[ $type == 'flag' ]]; then
      if [[ $is_short && $value ]]; then
        # In this case, the "value" will be other options, so put them back
        set -- "-$value" "$@"
      elif [[ $arg == *=* ]]; then
        throw "$option does not take a value"
      fi
      value=1
    elif [[ ($is_short && ! $value) || (! $is_short && $arg != *=*) ]]; then
      # Value should be the following arg
      if (( $# == 0 )); then
        throw "$option expects a value"
      fi
      value=$1
      shift
    fi

    # Run the callback if there is one. "{}" will be replaced with $value (which
    # is also in scope, but shellcheck will complain about using a variable in
    # a single-quoted string; this way looks cleaner anyway)
    if [[ ${callbacks[$option]} ]]; then
      eval "${callbacks[$option]//\{\}/\$value}"
    fi

    # shellcheck disable=SC2034 # OPTS appears unused
    for x in ${aliases[$option]}; do
      x=${x#-}
      x=${x#-}
      OPTS[$x]=$value

      # Call help() automatically if --help or any of its aliases are given
      # (this is done here at the end rather than when $callback is set since at
      # that point we haven't yet parsed the option names out of the descriptor)
      if [[ $x == 'help' && ! ${callbacks[$option]} ]] && declare -F help >/dev/null; then
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
