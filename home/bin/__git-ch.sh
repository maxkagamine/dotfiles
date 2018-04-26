#!/usr/bin/env bash

# TODO: Might break if branch name wraps. Maybe replace with fzf? See bashrc.
# Ctrl+C horribly broken when run from git alias... GfW being buggy as usual?

# Show help

if [[ $1 =~ ^(-h|--help)$ ]]; then
	cat >&2 <<-'EOF'
		git ch [-a] [<search>...]

		Interactive `git checkout` in the format of `git branch`. Arrow keys, W/S,
		or I/K to select a branch; Enter to check out; Del to delete; Q to cancel.

		-a        Show all branches, including remote-tracking.

		<search>  Partial branch name by which to filter the list. If multiple are
		          given, branches matching any of the search strings are shown.
	EOF
	exit 1
fi

# Check if in git repo

git rev-parse --is-inside-work-tree > /dev/null || exit $?

# Get branches

opts=()

if [[ $1 == '-a' ]]; then
	opts+=(-a)
	shift
fi

opts+=(--list --)

for p in "$@"; do
	opts+=("*$p*")
done

mapfile -t branches < <(git branch "${opts[@]}" | cut -c3-)

if [[ ${#branches[@]} == 0 ]]; then
	# New repo or no results; exit with 0 as `git branch` does
	exit
fi

# Find current branch

cur=0

if curbranch=$(git symbolic-ref -q --short HEAD); then
	for i in "${!branches[@]}"; do
		if [[ ${branches[$i]} == "$curbranch" ]]; then
			cur=$i
			break
		fi
	done
fi

# Build menu

while true; do

	# Output branch list

	for i in "${!branches[@]}"; do

		[[ $i == $cur ]] && printf '* ' || printf '  '

		if [[ ${branches[$i]} =~ ^remotes/origin/ ]]; then
			if [[ $i == $cur ]]; then
				echo -e "\e[31mremotes/origin/\e[32m${branches[$i]:15}\e[m"
			else
				echo -e "\e[31m${branches[$i]}\e[m"
			fi
		elif [[ $i == $cur ]]; then
			echo -e "\e[32m${branches[$i]}\e[m"
		else
			echo "${branches[$i]}"
		fi

	done

	# Read keypress (http://stackoverflow.com/a/11759139)

	read -sN1 key
	read -sN1 -t 0.0001 k2
	read -sN1 -t 0.0001 k3
	read -sN1 -t 0.0001 k4
	key+=${k2}${k3}${k4}

	case $key in
		w|i|$'\e[A'|$'\e0A') (( cur > 0 )) && (( cur-- )) ;; # up
		s|k|$'\e[B'|$'\e0B') (( cur < ${#branches[@]} - 1 )) && (( cur++ )) ;; # down
		''|$'\n') break ;; # enter
		$'\e[3~') # delete
			if [[ ! ${branches[$cur]} =~ ^(remotes/origin/|\(HEAD\ detached\ at) ]]; then
				echo
				if ! git branch -d "${branches[$cur]}"; then
					printf '\nForce delete? [Yn] '
					read -sN1 yn; echo
					if [[ ! $yn =~ ^[Nn] ]]; then
						echo
						git branch -D "${branches[$cur]}"
					fi
				fi
				exit
			fi
			;;
		q) exit ;;
	esac

	# Move back up to rewrite list on next loop

	tput cuu "${#branches[@]}"

done

# Switch to selected branch

selected=${branches[$cur]}

if [[ $selected =~ ^remotes/origin/ ]]; then
	selected=${selected:15}
fi

if [[ $selected != $curbranch && ! $selected =~ ^\(HEAD\ detached\ at ]]; then
	echo
	git checkout "$selected"
fi
