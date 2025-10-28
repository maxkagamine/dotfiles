# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

throw() {
  printf '%s: %s\n' "${0##*/}" "$1" >&2
  return 1
}

parse_args() {
  local flags=()
  local params=()
  declare -A aliases
  local descriptor
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

      aliases[$x]=${names[*]}
      if [[ $descriptor == *= ]]; then
        params+=("$x")
      else
        flags+=("$x")
      fi
    done
  done

  # OPTS will hold all of the passed options (and all of their aliases), leading
  # dashes omitted, mapped to their values (or 1 if a flag), while REST will
  # hold all positional parameters
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
    type=
    for x in "${flags[@]}"; do
      if [[ $x == "$option" ]]; then
        type=flag
        break
      fi
    done
    if [[ ! $type ]]; then
      for x in "${params[@]}"; do
        if [[ $x == "$option" ]]; then
          type=param
          break
        fi
      done
    fi
    if [[ ! $type ]]; then
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

    # shellcheck disable=SC2034 # OPTS appears unused
    for x in ${aliases[$option]}; do
      x=${x#-}
      x=${x#-}
      OPTS[$x]=$value

      # Call help() automatically if --help or any of its aliases are given
      if [[ $x == 'help' ]] && declare -F help >/dev/null; then
        if [[ (-t 2 || $FORCE_COLOR) && ! $NO_COLOR ]]; then
          # Auto-colorize options and headers (cargo-style)
          help 2>&1 | perl -e '
            my $pattern = join("|", sort { length $b <=> length $a } @ARGV);
            while (<STDIN>) {
              s/$pattern/\e[36m$&\e[m/g;
              s/^[A-Z].*?:/\e[32m$&\e[m/;
              print;
            }
          ' -- "${flags[@]}" "${params[@]}" >&2
        else
          help
        fi
      fi
    done
  done
}
