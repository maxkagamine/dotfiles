# bash completion for gpg                                  -*- shell-script -*-

# Edited to remove carraige returns from GPG4Win, courtesy of
# https://developers.yubico.com/PGP/SSH_authentication/Windows.html

_gpg()
{
    local cur prev words cword
    _init_completion || return

    case $prev in
        -s|--sign|--clearsign|--decrypt-files|--load-extension)
            _filedir
            return
            ;;
        --export|--sign-key|--lsign-key|--nrsign-key|--nrlsign-key|--edit-key)
            # return list of public keys
            COMPREPLY=( $( compgen -W "$( $1 --list-keys 2>/dev/null | sed "s/\r$//" | command sed -ne \
                's@^pub.*/\([^ ]*\).*$@\1@p' -ne \
                's@^.*\(<\([^>]*\)>\).*$@\2@p' )" -- "$cur" ) )
            return
            ;;
        -r|--recipient)
            COMPREPLY=( $( compgen -W "$( $1 --list-keys 2>/dev/null | sed "s/\r$//" | command sed -ne \
                's@^.*<\([^>]*\)>.*$@\1@p')" -- "$cur" ) )
            if [[ -e ~/.gnupg/gpg.conf ]]; then
                COMPREPLY+=( $( compgen -W "$( command sed -ne \
                    's@^[ \t]*group[ \t][ \t]*\([^=]*\).*$@\1@p' \
                    ~/.gnupg/gpg.conf  )" -- "$cur" ) )
            fi
            return
        ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '$($1 --dump-options | sed "s/\r$//")' -- "$cur" ) )
    fi
} &&
complete -F _gpg -o default gpg

# ex: filetype=sh
