# shellcheck shell=bash

pdf() {
  local paths temp_jpgs f output=''
  paths=()
  temp_jpgs=()
  while (( $# > 0 )); do
    case $1 in
      -o|--output)
        shift
        output=$1
        ;;
      -*)
        echo "unknown option: $1" >&2
        return 1
        ;;
      *)
        paths+=("$1")
        ;;
    esac
    shift
  done
  if [[ ${#paths[@]} == 0 || ! $output ]]; then
    echo 'Usage: pdf <images...> -o <output.pdf>' >&2
    return 1
  fi
  for f in "${paths[@]}"; do
    magick "$f" -quality 50 "${f}.temp.jpg" || return $?
    temp_jpgs+=("$_")
  done
  img2pdf --output "$output" "${temp_jpgs[@]}" || return $?
  rm "${temp_jpgs[@]}"
}
