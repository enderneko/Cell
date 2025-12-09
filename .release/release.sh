#!/usr/bin/env bash

# release.sh generates an addon zip file from a Git, SVN, or Mercurial checkout.
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

# Global shellcheck excludes:
#   SC2295: Expansions inside ${..} need to be quoted separately, otherwise they will match as a pattern.
#   SC2030: Modification of var is local (to subshell caused by pipeline).
#   SC2031: var was modified in a subshell. That change might be lost.
#   SC2317: Command appears to be unreachable.
# shellcheck disable=SC2295,SC2030,SC2031,SC2317

## USER OPTIONS

# Secrets for uploading
cf_token=
github_token=
wowi_token=
wago_token=

# Variables set via command-line options
slug=
addonid=
wagoid=
topdir=
releasedir=
overwrite=
nolib=
split=
line_ending="dos"
skip_copying=
skip_externals=
skip_localization=
skip_zipfile=
skip_upload=true
skip_cf_upload=true
pkgmeta_file=
game_version=
game_type=
file_type=
file_template="{package-name}-{project-version}{nolib}{classic}"
label_template="{project-version}{classic}{nolib}"

wowi_markup="bbcode"

## END USER OPTIONS

if [[ ${BASH_VERSINFO[0]} -lt 4 ]] || [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 3 ]]; then
	echo "ERROR! bash version 4.3 or above is required. Your version is ${BASH_VERSION}." >&2
	exit 1
fi

# Game versions for uploading
declare -A game_flavor=( ["retail"]="retail" ["classic"]="classic" ["bcc"]="bcc" ["mainline"]="retail" ["tbc"]="bcc" ["vanilla"]="classic" ["wrath"]="wrath" ["wotlkc"]="wrath" ["cata"]="cata" ["mists"]="mists" )

declare -A game_type_version=()           # type -> version (: delim)
declare -A game_type_interface=()         # type -> toc (: delim)
declare -A si_game_type_interface_all=()  # type -> interface value (last file)  (values from ## Interface*:)
declare -A si_game_type_interface=()      # type -> game type interface value (last file)  (values from ## Interface-Type:)
declare    si_game_root_interface         # base interface value (last file)
declare -A toc_interfaces=()              # path -> si_game_type_interface_all (: delim)
declare -A toc_root_interface=()          # path -> base interface value  (values from ## Interface:)
declare -A toc_root_paths=()              # path -> directory name
declare -a toc_paths=()                   # toc path in order of processing

# Script return code
exit_code=0

retry() {
	local result=0
	local count=1
	local max=10
	while [[ $count -le "$max" ]]; do
		[[ $result -ne 0 ]] && {
			echo -e "\033[01;31mRetrying (${count}/${max})\033[0m" >&2
		}
		"$@" && { result=0 && break; } || result="$?"
		count="$((count + 1))"
		sleep 3
	done
	# shellcheck disable=SC2086
	return $result
}

retry_svn_checkout() {
	local repo="$1"
	local path="$2"
	local result=0
	local count=1
	local max=5
	while [[ $count -le "$max" ]]; do
		[[ $result -ne 0 ]] && {
			echo -e "\033[01;31mRetrying (${count}/${max})\033[0m" >&2
			rm -rf "$path" # an aborted checkout can leave a .svn directory with a locked state
		}
		svn checkout -q "$repo" "$path" --force && { result=0 && break; } || result="$?"
		count="$((count + 1))"
		sleep 3
	done
	# shellcheck disable=SC2086
	return $result
}

# Escape a string for use in sed substitutions.
escape_substr() {
	local s="$1"
	s=${s//\\/\\\\}
	s=${s//\//\\/}
	s=${s//&/\\&}
	echo "$s"
}

# File name templating
filename_filter() {
	local classic alpha beta invalid="_"
	[ -n "$skip_invalid" ] && invalid="&"
	if [[ -n $game_type ]] && [[ "$game_type" != "retail" ]] && \
		 [[ "$game_type" != "classic" || "${si_project_version,,}" != *"-classic"* ]] &&\
		 [[ "$game_type" != "bcc" || "${si_project_version,,}" != *"-bcc"* ]] &&\
		 [[ "$game_type" != "wrath" || "${si_project_version,,}" != *"-wrath"* ]] &&\
		 [[ "$game_type" != "cata" || "${si_project_version,,}" != *"-cata"* ]] &&\
		 [[ "$game_type" != "mists" || "${si_project_version,,}" != *"-mists"* ]]
	then
		# only append the game type if the tag doesn't include it
		classic="-$game_type"
	fi
	[ "$file_type" == "alpha" ] && alpha="-alpha"
	[ "$file_type" == "beta" ] && beta="-beta"
	sed \
		-e "s/{package-name}/$( escape_substr "$package" )/g" \
		-e "s/{project-revision}/$si_project_revision/g" \
		-e "s/{project-hash}/$si_project_hash/g" \
		-e "s/{project-abbreviated-hash}/$si_project_abbreviated_hash/g" \
		-e "s/{project-author}/$( escape_substr "$si_project_author" )/g" \
		-e "s/{project-date-iso}/$si_project_date_iso/g" \
		-e "s/{project-date-integer}/$si_project_date_integer/g" \
		-e "s/{project-timestamp}/$si_project_timestamp/g" \
		-e "s/{project-version}/$( escape_substr "$si_project_version" )/g" \
		-e "s/{game-type}/${game_type}/g" \
		-e "s/{release-type}/${file_type}/g" \
		-e "s/{alpha}/${alpha}/g" \
		-e "s/{beta}/${beta}/g" \
		-e "s/{nolib}/${nolib:+-nolib}/g" \
		-e "s/{classic}/${classic}/g" \
		-e "s/\([^A-Za-z0-9._-]\)/${invalid}/g" \
		<<< "$1"
}

toc_filter() {
	local keyword="$1"
	local remove="$2"
	if [ -z "$remove" ]; then
		# "active" build type: remove comments (keep content), remove non-blocks (remove all)
		sed \
			-e "/#@\(end-\)\{0,1\}${keyword}@/d" \
			-e "/#@non-${keyword}@/,/#@end-non-${keyword}@/d"
	else
		# "non" build type: remove blocks (remove content), uncomment non-blocks (remove tags)
		sed \
			-e "/#@${keyword}@/,/#@end-${keyword}@/d" \
			-e "/#@non-${keyword}@/,/#@end-non-${keyword}@/s/^#[[:blank:]]\{1,\}//" \
			-e "/#@\(end-\)\{0,1\}non-${keyword}@/d"
	fi
}

toc_to_type() {
	local toc_version="$1"
	local -n game_type="$2" || return 1
	case $toc_version in
		11???) game_type="classic" ;;
		20???) game_type="bcc" ;;
		30???) game_type="wrath" ;;
		40???) game_type="cata" ;;
		50???) game_type="mists" ;;
		*) game_type="retail"
	esac
	# return game_type
}

is_toc_multiple_types() {
	local toc_version="$1"
	local toc_game_type toc_version_game_type
	IFS=':,' read -ra V <<< "$toc_version"
	toc_to_type "${V[0]}" "toc_game_type"
	for i in "${V[@]}"; do
		toc_to_type "$i" "toc_version_game_type"
		[[ $toc_game_type != "$toc_version_game_type" ]] && return 0
	done
	return 1
}


# Process command-line options
usage() {
	cat <<-'EOF' >&2
	Usage: release.sh [options]
	  -c               Skip copying files into the package directory.
	  -d               Skip uploading.
	  -e               Skip checkout of external repositories.
	  -l               Skip @localization@ keyword replacement.
	  -L               Only do @localization@ keyword replacement (skip upload to CurseForge).
	  -o               Keep existing package directory, overwriting its contents.
	  -s               Create a stripped-down "nolib" package.
	  -S               Create a package supporting multiple game types from a single TOC file.
	  -u               Use Unix line-endings.
	  -z               Skip zip file creation.
	  -t topdir        Set top-level directory of checkout.
	  -r releasedir    Set directory containing the package directory. Defaults to "$topdir/.release".
	  -p curse-id      Set the project id used on CurseForge for localization and uploading. (Use 0 to unset the TOC value)
	  -w wowi-id       Set the addon id used on WoWInterface for uploading. (Use 0 to unset the TOC value)
	  -a wago-id       Set the project id used on Wago Addons for uploading. (Use 0 to unset the TOC value)
	  -g game-version  Set the game version to use for uploading.
	  -m pkgmeta.yaml  Set the pkgmeta file to use.
	  -n "{template}"  Set the package zip file name and upload label. Use "-n help" for more info.
	EOF
}

OPTIND=1
while getopts ":celLzusSop:dw:a:r:t:g:m:n:" opt; do
	case $opt in
		c) skip_copying="true" ;; # Skip copying files into the package directory
		z) skip_zipfile="true" ;; # Skip creating a zip file
		e) skip_externals="true" ;; # Skip checkout of external repositories
		l) skip_localization="true" ;; # Skip @localization@ keyword replacement
		L) skip_cf_upload="true" ;; # Skip uploading to CurseForge
		d) skip_upload="true" ;; # Skip uploading
		u) line_ending="unix" ;; # Use LF instead of CRLF as the line ending for all text files
		o) overwrite="true" ;; # Don't delete existing directories in the release directory
		p) slug="$OPTARG" ;; # Set CurseForge project id
		w) addonid="$OPTARG" ;; # Set WoWInterface addon id
		a) wagoid="$OPTARG" ;; # Set Wago Addons project id
		r) releasedir="$OPTARG" ;; # Set the release directory
		t) # Set the top-level directory of the checkout
			if [ ! -d "$OPTARG" ]; then
				echo "Invalid argument for option \"-t\" - Directory \"$OPTARG\" does not exist." >&2
				usage
				exit 1
			fi
			topdir="$OPTARG"
			;;
		s) # Create a nolib package without externals
			nolib="true"
			skip_externals="true"
			;;
		S) split="true" ;; # Split TOC
		g) # Set the game type or version
			OPTARG="${OPTARG,,}"
			case "$OPTARG" in
				retail|classic|bcc|wrath|cata|mists) game_type="$OPTARG" ;; # game_version from toc
				mainline) game_type="retail" ;;
				*)
					# Set game version (x.y.z)
					# Build game type set from the last value if a list
					IFS=',' read -ra V <<< "$OPTARG"
					for i in "${V[@]}"; do
						if [[ ! "$i" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)[a-z]?$ ]]; then
							echo "Invalid argument for option \"-g\" ($i)" >&2
							usage
							exit 1
						fi
						if [[ ${BASH_REMATCH[1]} == "1" ]]; then
							game_type="classic"
						elif [[ ${BASH_REMATCH[1]} == "2" ]]; then
							game_type="bcc"
						elif [[ ${BASH_REMATCH[1]} == "3" ]]; then
							game_type="wrath"
						elif [[ ${BASH_REMATCH[1]} == "4" ]]; then
							game_type="cata"
						elif [[ ${BASH_REMATCH[1]} == "5" ]]; then
							game_type="mists"
						else
							game_type="retail"
						fi
						if [[ -n ${game_type_version[$game_type]} ]]; then
							game_type_version[$game_type]="${game_type_version[$game_type]}:$i"
							game_type_interface[$game_type]="${game_type_interface[$game_type]}:$( printf "%d%02d%02d" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" )"
						else
							game_type_version[$game_type]="$i"
							game_type_interface[$game_type]=$( printf "%d%02d%02d" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" )
						fi
					done
					if [[ ${#game_type_version[@]} -gt 1 ]]; then
						game_type=
					fi
					game_version="$OPTARG"
			esac
			;;
		m) # Set the pkgmeta file
			if [ ! -f "$OPTARG" ]; then
				echo "Invalid argument for option \"-m\" - File \"$OPTARG\" does not exist." >&2
				usage
				exit 1
			fi
			pkgmeta_file="$OPTARG"
			;;
		n) # Set the package file name
			if [ "$OPTARG" = "help" ]; then
				cat <<-'EOF' >&2
				Usage: release.sh [options]
				  Set the package zip file name and upload file label. There are several string
				  substitutions you can use to include version control and build type information in
				  the file name and upload label.

				  The default file name is "{package-name}-{project-version}{nolib}{classic}".
				  The default upload label is "{project-version}{classic}{nolib}".

				  To set both, separate with a ":", i.e, "{file template}:{label template}".
				  If either side of the ":" is blank, the default will be used.Not including a ":"
				  will set the file name template, leaving upload label as default.

				  Tokens: {package-name}{project-revision}{project-hash}{project-abbreviated-hash}
				          {project-author}{project-date-iso}{project-date-integer}{project-timestamp}
				          {project-version}{game-type}{release-type}

				  Flags:  {alpha}{beta}{nolib}{classic}

				  Tokens are always replaced with their value. Flags are shown prefixed with a dash
				  depending on the build type.
				EOF
				exit 0
			fi
			if skip_invalid=true filename_filter "$OPTARG" | grep -q '[{}]'; then
				tokens=$( skip_invalid=true filename_filter "$OPTARG" | sed -e '/^[^{]*{\|}[^{]*{\|}[^{]*/s//}{/g' -e 's/^}\({.*}\){$/\1/' )
				echo "Invalid argument for option \"-n\" - Invalid substitutions: $tokens" >&2
				exit 1
			fi
			file_template=${OPTARG%%:*}
			if [ -z "$file_template" ]; then
				file_template="{package-name}-{project-version}{nolib}{classic}"
			fi
			label_template=${OPTARG##*:}
			if [ -z "$label_template" ]; then
				label_template="{project-version}{classic}{nolib}"
			fi
			#"{package-name}-{project-version}{nolib}{classic}:{project-version}{classic}{nolib}"
			;;
		:)
			echo "Option \"-$OPTARG\" requires an argument." >&2
			usage
			exit 1
			;;
		\?)
			if [ "$OPTARG" = "?" ] || [ "$OPTARG" = "h" ]; then
				usage
				exit 0
			fi
			echo "Unknown option \"-$OPTARG\"" >&2
			usage
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

# Set $topdir to top-level directory of the checkout.
if [ -z "$topdir" ]; then
	dir=$( pwd )
	if [ -d "$dir/.git" ] || [ -d "$dir/.svn" ] || [ -d "$dir/.hg" ]; then
		topdir=.
	else
		dir=${dir%/*}
		topdir=".."
		while [ -n "$dir" ]; do
			if [ -d "$topdir/.git" ] || [ -d "$topdir/.svn" ] || [ -d "$topdir/.hg" ]; then
				break
			fi
			dir=${dir%/*}
			topdir="$topdir/.."
		done
		if [ ! -d "$topdir/.git" ] && [ ! -d "$topdir/.svn" ] && [ ! -d "$topdir/.hg" ]; then
			echo "No Git, SVN, or Hg checkout found." >&2
			exit 1
		fi
	fi
fi

# Handle folding sections in CI logs
start_group() { echo "$1"; }
end_group() { echo; }

# Check for Travis CI
if [ -n "$TRAVIS" ]; then
	# Don't run the packager for pull requests
	if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
		echo "Not packaging pull request."
		exit 0
	fi
	if [ -z "$TRAVIS_TAG" ]; then
		# Don't run the packager if there is a tag pending
		check_tag=$( git -C "$topdir" tag --points-at HEAD )
		if [ -n "$check_tag" ]; then
			echo "Found future tag \"${check_tag}\", not packaging."
			exit 0
		fi
		# Only package master, classic, or develop
		if [ "$TRAVIS_BRANCH" != "master" ] && [ "$TRAVIS_BRANCH" != "classic" ] && [ "$TRAVIS_BRANCH" != "develop" ]; then
			echo "Not packaging \"${TRAVIS_BRANCH}\"."
			exit 0
		fi
	fi
	# https://github.com/travis-ci/travis-build/tree/master/lib/travis/build/bash
	start_group() {
		echo -en "travis_fold:start:$2\\r\033[0K"
		# release_timer_id="$(printf %08x $((RANDOM * RANDOM)))"
		# release_timer_start_time="$(date -u +%s%N)"
		# echo -en "travis_time:start:${release_timer_id}\\r\033[0K"
		echo "$1"
	}
	end_group() {
		# local release_timer_end_time="$(date -u +%s%N)"
		# local duration=$((release_timer_end_time - release_timer_start_time))
		# echo -en "\\ntravis_time:end:${release_timer_id}:start=${release_timer_start_time},finish=${release_timer_end_time},duration=${duration}\\r\033[0K"
		echo -en "travis_fold:end:$1\\r\033[0K"
	}
fi

# Check for GitHub Actions
if [[ -n $GITHUB_ACTIONS ]]; then
	# Prevent duplicate builds from multiple pushes
	if [[ $GITHUB_EVENT_NAME == "push" && $GITHUB_REF == "refs/heads"* ]]; then
		check_tag=$( git -C "$topdir" tag --points-at HEAD )
		if [[ -n $check_tag ]]; then
			echo "Found future tag \"${check_tag}\", not packaging."
			exit 0
		fi
		unset check_tag
	fi
	start_group() { echo "##[group]$1"; }
	end_group() { echo "##[endgroup]"; }
fi

# Load secrets
if [ -f "$topdir/.env" ]; then
	# shellcheck disable=SC1090,SC1091
	. "$topdir/.env"
elif [ -f ".env" ]; then
	# shellcheck disable=SC1091
	. ".env"
fi
[ -z "$cf_token" ] && cf_token=$CF_API_KEY
[ -z "$github_token" ] && github_token=$GITHUB_OAUTH
[ -z "$wowi_token" ] && wowi_token=$WOWI_API_TOKEN
[ -z "$wago_token" ] && wago_token=$WAGO_API_TOKEN

# Set $releasedir to the directory which will contain the generated addon zipfile.
if [ -z "$releasedir" ]; then
	releasedir="$topdir/.release"
fi

# Set $basedir to the basename of the checkout directory.
basedir=$( cd "$topdir" && pwd )
case $basedir in
	/*/*) basedir=${basedir##/*/} ;;
	/*) basedir=${basedir##/} ;;
esac

# Set $repository_type to "git" or "svn" or "hg".
repository_type=
if [ -d "$topdir/.git" ]; then
	repository_type=git
elif [ -d "$topdir/.svn" ]; then
	repository_type=svn
elif [ -d "$topdir/.hg" ]; then
	repository_type=hg
else
	echo "No Git, SVN, or Hg checkout found in \"$topdir\"." >&2
	exit 1
fi

# $releasedir must be an absolute path or inside $topdir.
case $releasedir in
	/*) ;;
	$topdir/*) ;;
	*)
		echo "The release directory \"$releasedir\" must be an absolute path or inside \"$topdir\"." >&2
		exit 1
		;;
esac

# Create the staging directory.
mkdir -p "$releasedir" 2>/dev/null || {
	echo "Unable to create the release directory \"$releasedir\"." >&2
	exit 1
}

# Expand $topdir and $releasedir to their absolute paths for string comparisons later.
topdir=$( cd "$topdir" && pwd )
releasedir=$( cd "$releasedir" && pwd )

###
### set_info_<repo> returns the following information:
###
si_repo_type= # "git" or "svn" or "hg"
si_repo_dir= # the checkout directory
si_repo_url= # the checkout url
si_tag= # tag for HEAD
si_previous_tag= # previous tag
si_previous_revision= # [SVN|Hg] revision number for previous tag

si_project_revision= # Turns into the highest revision of the entire project in integer form, e.g. 1234, for SVN. Turns into the commit count for the project's hash for Git.
si_project_hash= # [Git|Hg] Turns into the hash of the entire project in hex form. e.g. 106c634df4b3dd4691bf24e148a23e9af35165ea
si_project_abbreviated_hash= # [Git|Hg] Turns into the abbreviated hash of the entire project in hex form. e.g. 106c63f
si_project_author= # Turns into the last author of the entire project. e.g. ckknight
si_project_date_iso= # Turns into the last changed date (by UTC) of the entire project in ISO 8601. e.g. 2008-05-01T12:34:56Z
si_project_date_integer= # Turns into the last changed date (by UTC) of the entire project in a readable integer fashion. e.g. 2008050123456
si_project_timestamp= # Turns into the last changed date (by UTC) of the entire project in POSIX timestamp. e.g. 1209663296
si_project_version= # Turns into an approximate version of the project. The tag name if on a tag, otherwise it's up to the repo. SVN returns something like "r1234", Git returns something like "v0.1-873fc1"

si_file_revision= # Turns into the current revision of the file in integer form, e.g. 1234, for SVN. Turns into the commit count for the file's hash for Git.
si_file_hash= # Turns into the hash of the file in hex form. e.g. 106c634df4b3dd4691bf24e148a23e9af35165ea
si_file_abbreviated_hash= # Turns into the abbreviated hash of the file in hex form. e.g. 106c63
si_file_author= # Turns into the last author of the file. e.g. ckknight
si_file_date_iso= # Turns into the last changed date (by UTC) of the file in ISO 8601. e.g. 2008-05-01T12:34:56Z
si_file_date_integer= # Turns into the last changed date (by UTC) of the file in a readable integer fashion. e.g. 20080501123456
si_file_timestamp= # Turns into the last changed date (by UTC) of the file in POSIX timestamp. e.g. 1209663296

si_build_timestamp=$( date "+%s" )
si_build_date=$( TZ='' printf "%(%Y-%m-%d)T" "$si_build_timestamp" )
si_build_date_iso=$( TZ='' printf "%(%Y-%m-%dT%H:%M:%SZ)T" "$si_build_timestamp" )
si_build_date_integer=$( TZ='' printf "%(%Y%m%d%H%M%S)T" "$si_build_timestamp" )

# SVN date helper function
strtotime() {
	local value="$1" # datetime string
	local format="$2" # strptime string
	if [[ "$OSTYPE" == "darwin"* || "$OSTYPE" == *"bsd"* ]]; then # bsd
		date -j -f "$format" "$value" "+%s" 2>/dev/null
	else # gnu
		date -d "$value" +%s 2>/dev/null
	fi
}

set_info_git() {
	si_repo_dir="$1"
	si_repo_type="git"
	si_repo_url=$( git -C "$si_repo_dir" remote get-url origin 2>/dev/null | sed -e 's/^git@\(.*\):/https:\/\/\1\//' )
	if [ -z "$si_repo_url" ]; then # no origin so grab the first fetch url
		si_repo_url=$( git -C "$si_repo_dir" remote -v | awk '/(fetch)/ { print $2; exit }' | sed -e 's/^git@\(.*\):/https:\/\/\1\//' )
	fi

	# Populate filter vars.
	si_project_hash=$( git -C "$si_repo_dir" show --no-patch --format="%H" 2>/dev/null )
	si_project_abbreviated_hash=$( git -C "$si_repo_dir" show --no-patch --abbrev=7 --format="%h" 2>/dev/null )
	si_project_author=$( git -C "$si_repo_dir" show --no-patch --format="%an" 2>/dev/null )
	si_project_timestamp=$( git -C "$si_repo_dir" show --no-patch --format="%at" 2>/dev/null )
	si_project_date_iso=$( TZ='' printf "%(%Y-%m-%dT%H:%M:%SZ)T" "$si_project_timestamp" )
	si_project_date_integer=$( TZ='' printf "%(%Y%m%d%H%M%S)T" "$si_project_timestamp" )
	# XXX --depth limits rev-list :\ [ -s "$si_repo_dir/$(git rev-parse --git-dir)/shallow" ] && git -C "$si_repo_dir" fetch --quiet --unshallow --no-tags
	# actions/checkout using clone --filter=blob:none instead of their current unholy abomination would be nice
	si_project_revision=$( git -C "$si_repo_dir" rev-list --count "$si_project_hash" 2>/dev/null )

	# Get the tag for the HEAD.
	si_previous_tag=
	si_previous_revision=
	# git describe should use the latest tag if there are multiple, but it doesn't always work that way.
	local _si_tag check_tag=()
	while IFS='' read -r tag; do check_tag+=( "$tag" ); done < <( git -C "$si_repo_dir" tag --points-at HEAD --sort=-committerdate --sort=-v:refname --sort=-taggerdate )
	if [[ ${#check_tag[@]} -gt 0 ]]; then
		# Use the most recent tag
		si_tag="${check_tag[0]}"
		_si_tag="$si_tag"

		if [[ $GITHUB_REF == "refs/tags/"* && $si_tag != "$GITHUB_REF_NAME" ]]; then
			# Git doesn't agree with GitHub Actions, check if there is another local tag that matches
			for tag in "${check_tag[@]}"; do
				if [[ $tag == "$GITHUB_REF_NAME" ]]; then
					si_tag="$tag"
					_si_tag="$si_tag"
					break
				fi
			done
		fi
	else
		_si_tag=$( git -C "$si_repo_dir" describe --tags --always --abbrev=7 2>/dev/null )
		si_tag=$( git -C "$si_repo_dir" describe --tags --always --abbrev=0 2>/dev/null )
	fi
	# Set $si_project_version to the version number of HEAD.
	si_project_version="$si_tag"
	# The HEAD is not tagged if the HEAD is several commits past the most recent tag.
	if [[ $si_tag == "$si_project_hash" ]]; then
		# --abbrev=0 expands out the full sha if there was no previous tag
		si_project_version="$_si_tag"
		si_previous_tag=
		si_tag=
	elif [[ $_si_tag != "$si_tag" ]]; then
		# not on a tag
		si_project_version=$( git -C "$si_repo_dir" describe --tags --abbrev=7 --exclude="*[Aa][Ll][Pp][Hh][Aa]*" 2>/dev/null )
		if [[ -n $si_project_version ]]; then
			si_previous_tag=$( git -C "$si_repo_dir" describe --tags --abbrev=0 --exclude="*[Aa][Ll][Pp][Hh][Aa]*" 2>/dev/null )
		else # no previous non-alpha tag
			si_project_version="$_si_tag"
			si_previous_tag=
		fi
		si_tag=
	else # we're on a tag, just jump back one commit
		if [[ ${si_tag,,} != *"beta"* && ${si_tag,,} != *"alpha"* ]]; then
			# full release, ignore beta tags
			si_previous_tag=$( git -C "$si_repo_dir" describe --tags --abbrev=0 --exclude="*[Aa][Ll][Pp][Hh][Aa]*" --exclude="*[Bb][Ee][Tt][Aa]*" HEAD~ 2>/dev/null )
		else
			si_previous_tag=$( git -C "$si_repo_dir" describe --tags --abbrev=0 --exclude="*[Aa][Ll][Pp][Hh][Aa]*" HEAD~ 2>/dev/null )
		fi
	fi
}

set_info_svn() {
	si_repo_dir="$1"
	si_repo_type="svn"

	local _si_svninfo _si_url _si_revision _si_tag_line _si_tag _si_tag_from_revision _si_timestamp
	_si_svninfo=$( retry svn info -r BASE "$si_repo_dir" 2>/dev/null )
	if [[ -z "$_si_svninfo" ]]; then
		echo "Unable to read svn repo at $si_repo_dir" >&2
		exit 1
	fi

	si_repo_url=$( awk '/^Repository Root:/ { print $3; exit }' <<< "$_si_svninfo" )
	_si_url=$( awk '/^URL:/ { print $2; exit }' <<< "$_si_svninfo" )
	_si_revision=$( awk '/^Last Changed Rev:/ { print $NF; exit }' <<< "$_si_svninfo" )

	case ${_si_url#"${si_repo_url}"/} in
		tags/*)
			# Extract the tag from the URL.
			si_tag=${_si_url#"${si_repo_url}"/tags/}
			si_tag=${si_tag%%/*}
			si_project_revision="$_si_revision"
			;;
		*)
			# Check if the latest tag matches the working copy revision (/trunk checkout instead of /tags)
			_si_tag_line=$( retry svn log --verbose --limit 1 "$si_repo_url/tags" 2>/dev/null | awk '/^   A/ { print $0; exit }' )
			_si_tag=$( echo "$_si_tag_line" | awk '/^   A/ { print $2 }' | awk -F/ '{ print $NF }' )
			# (from /project/trunk:REV)
			_si_tag_from_revision=${_si_tag_line##*:}
			_si_tag_from_revision=${_si_tag_from_revision%)*}

			if [[ "$_si_tag_from_revision" == "$_si_revision" ]]; then
				si_tag="$_si_tag"
				si_project_revision=$( retry svn info "$si_repo_url/tags/$si_tag" 2>/dev/null | awk '/^Last Changed Rev:/ { print $NF; exit }' )
			else
				# Set $si_project_revision to the highest revision of the project at the checkout path
				si_project_revision=$( svn info --recursive "$si_repo_dir" 2>/dev/null | awk '/^Last Changed Rev:/ { print $NF }' | sort -nr | head -n1 )
			fi
			;;
	esac

	if [[ -n "$si_tag" ]]; then
		si_project_version="$si_tag"
	else
		si_project_version="r$si_project_revision"
	fi

	# Get the previous tag and it's revision
	_si_tag=$( retry svn log --verbose --limit 1 "$si_repo_url/tags" -r $((si_project_revision - 1)):1 2>/dev/null | awk '/^   A/ { print $0; exit }' | awk '/^   A/ { print $2 }' | awk -F/ '{ print $NF }' )
	if [[ -n "$_si_tag" ]]; then
		si_previous_tag="$_si_tag"
		si_previous_revision=$( retry svn info "$si_repo_url/tags/$_si_tag" 2>/dev/null | awk '/^Last Changed Rev:/ { print $NF; exit }' )
	fi

	# Populate filter vars.
	si_project_author=$( awk '/^Last Changed Author:/ { print $0; exit }' <<< "$_si_svninfo" | cut -d" " -f4- )
	_si_timestamp=$( awk '/^Last Changed Date:/ { print $4,$5; exit }' <<< "$_si_svninfo" )
	si_project_timestamp=$( strtotime "$_si_timestamp" "%F %T" )
	si_project_date_iso=$( TZ='' printf "%(%Y-%m-%dT%H:%M:%SZ)T" "$si_project_timestamp" )
	si_project_date_integer=$( TZ='' printf "%(%Y%m%d%H%M%S)T" "$si_project_timestamp" )
	# SVN repositories have no project hash.
	si_project_hash=
	si_project_abbreviated_hash=
}

set_info_hg() {
	si_repo_dir="$1"
	si_repo_type="hg"
	si_repo_url=$( hg --cwd "$si_repo_dir" paths -q default )
	if [ -z "$si_repo_url" ]; then # no default so grab the first path
		si_repo_url=$( hg --cwd "$si_repo_dir" paths | awk '{ print $3; exit }' )
	fi

	# Populate filter vars.
	si_project_hash=$( hg --cwd "$si_repo_dir" log -r . --template '{node}' 2>/dev/null )
	si_project_abbreviated_hash=$( hg --cwd "$si_repo_dir" log -r . --template '{node|short}' 2>/dev/null )
	si_project_author=$( hg --cwd "$si_repo_dir" log -r . --template '{author}' 2>/dev/null )
	si_project_timestamp=$( hg --cwd "$si_repo_dir" log -r . --template '{date}' 2>/dev/null | cut -d. -f1 )
	si_project_date_iso=$( TZ='' printf "%(%Y-%m-%dT%H:%M:%SZ)T" "$si_project_timestamp" )
	si_project_date_integer=$( TZ='' printf "%(%Y%m%d%H%M%S)T" "$si_project_timestamp" )
	si_project_revision=$( hg --cwd "$si_repo_dir" log -r . --template '{rev}' 2>/dev/null )

	# Get tag info
	si_tag=
	# I'm just muddling through revsets, so there is probably a better way to do this
	# Ignore tag commits, so v1.0-1 will package as v1.0
	if [ "$( hg --cwd "$si_repo_dir" log -r '.-filelog(.hgtags)' --template '{rev}' 2>/dev/null )" == "" ]; then
		_si_tip=$( hg --cwd "$si_repo_dir" log -r 'last(parents(.))' --template '{rev}' 2>/dev/null )
	else
		_si_tip=$( hg --cwd "$si_repo_dir" log -r . --template '{rev}' 2>/dev/null )
	fi
	si_previous_tag=$( hg --cwd "$si_repo_dir" log -r "$_si_tip" --template '{latesttag}' 2>/dev/null )
	# si_project_version=$( hg --cwd "$si_repo_dir" log -r "$_si_tip" --template "{ ifeq(changessincelatesttag, 0, latesttag, '{latesttag}-{changessincelatesttag}-m{node|short}') }" 2>/dev/null ) # git style
	si_project_version=$( hg --cwd "$si_repo_dir" log -r "$_si_tip" --template "{ ifeq(changessincelatesttag, 0, latesttag, 'r{rev}') }" 2>/dev/null ) # svn style
	if [ "$si_previous_tag" = "$si_project_version" ]; then
		# we're on a tag
		si_tag=$si_previous_tag
		si_previous_tag=$( hg --cwd "$si_repo_dir" log -r "last(parents($_si_tip))" --template '{latesttag}' 2>/dev/null )
	fi
	si_previous_revision=$( hg --cwd "$si_repo_dir" log -r "$si_previous_tag" --template '{rev}' 2>/dev/null )
}

set_info_file() {
	local _si_file="$1"
	if [[ $si_repo_type == "git" ]]; then
		local _si_file_dir=${_si_file%/*} # set the working directory to file's directory to allow for submodule file info
		_si_file=${_si_file##*/} # just need the filename
		# Populate filter vars from the last commit the file was included in.
		si_file_author=$( git -C "$_si_file_dir" log --max-count=1 --format="%an" -- "$_si_file" 2>/dev/null )
		si_file_timestamp=$( git -C "$_si_file_dir" log --max-count=1 --format="%at" -- "$_si_file" 2>/dev/null )
		si_file_hash=$( git -C "$_si_file_dir" log --max-count=1 --format="%H" -- "$_si_file" 2>/dev/null )
		si_file_revision=$( git -C "$_si_file_dir" rev-list --count "$si_file_hash" 2>/dev/null ) # XXX checkout depth affects rev-list, see set_info_git
		si_file_abbreviated_hash=$( git -C "$_si_file_dir" log --max-count=1 --abbrev=7 --format="%h" -- "$_si_file" 2>/dev/null )

	elif [[ $si_repo_type == "svn" ]]; then
		local _sif_svninfo _si_timestamp
		_sif_svninfo=$( svn info "$_si_file" 2>/dev/null )
		if [[ -n $_sif_svninfo ]]; then
			# Populate filter vars.
			si_file_author=$( awk '/^Last Changed Author:/ { print $0; exit }' <<< "$_sif_svninfo" | cut -d" " -f4- )
			_si_timestamp=$( awk '/^Last Changed Date:/ { print $4,$5,$6; exit }' <<< "$_sif_svninfo" )
			si_file_timestamp=$( strtotime "$_si_timestamp" "%F %T %z" )
			si_file_revision=$( awk '/^Last Changed Rev:/ { print $NF; exit }' <<< "$_sif_svninfo" )
			# Use the file checksum.
			si_file_hash=$( awk '/^Checksum:/ { print $2; exit }' <<< "$_sif_svninfo" )
			si_file_abbreviated_hash=${si_file_hash:0:7}
		else
			si_file_author=
			si_file_timestamp=
			si_file_revision=
			si_file_hash=
			si_file_abbreviated_hash=
			si_file_date_iso=
			si_file_date_integer=
		fi

	elif [[ $si_repo_type == "hg" ]]; then
		# Populate filter vars.
		si_file_author=$( hg log --limit 1 --template '{author}' "$_si_file" 2>/dev/null )
		si_file_timestamp=$( hg log --limit 1 --template '{date}' "$_si_file" 2>/dev/null | cut -d. -f1 )
		si_file_revision=$( hg log --limit 1 --template '{rev}' "$_si_file" 2>/dev/null )
		si_file_hash=$( hg log --limit 1 --template '{node}' "$_si_file" 2>/dev/null )
		si_file_abbreviated_hash=$( hg log --limit 1 --template '{node|short}' "$_si_file" 2>/dev/null )

	fi
	if [[ -n $si_file_timestamp ]]; then
		si_file_date_iso=$( TZ='' printf "%(%Y-%m-%dT%H:%M:%SZ)T" "$si_file_timestamp" )
		si_file_date_integer=$( TZ='' printf "%(%Y%m%d%H%M%S)T" "$si_file_timestamp" )
	fi
}

# Set some version info about the project
echo -ne "Reading project repository..."
case $repository_type in
	git) set_info_git "$topdir" ;;
	svn) set_info_svn "$topdir" ;;
	hg)  set_info_hg  "$topdir" ;;
esac
echo -e "done\n"

tag=$si_tag
project_version=$si_project_version
previous_version=$si_previous_tag
project_hash=$si_project_hash
project_revision=$si_project_revision
previous_revision=$si_previous_revision
project_timestamp=$si_project_timestamp
project_github_url=
project_github_slug=
if [[ "$si_repo_url" == "https://github.com"* ]]; then
	project_github_url=${si_repo_url%.git}
	project_github_slug=${project_github_url#https://github.com/}
fi
project_site=

# Automatic file type detection based on CurseForge rules
# 1) Untagged commits will be marked as an alpha.
# 2) Tagged commits will be marked as a release with the following exceptions:
#    - If the tag contains the word "alpha", it will be marked as an alpha file.
#    - If instead the tag contains the word "beta", it will be marked as a beta file.
if [ -n "$tag" ]; then
	if [[ "${tag,,}" == *"alpha"* ]]; then
		file_type="alpha"
	elif [[ "${tag,,}" == *"beta"* ]]; then
		file_type="beta"
	else
		file_type="release"
	fi
else
	file_type="alpha"
fi

# Add some GitHub Actions outputs
if [[ -n $GITHUB_ACTIONS ]]; then
	# shellcheck disable=SC2129
	echo "project_version=${project_version}" >> "$GITHUB_OUTPUT"
	echo "previous_version=${previous_version}" >> "$GITHUB_OUTPUT"
	echo "project_hash=${project_hash}" >> "$GITHUB_OUTPUT"
	echo "project_timestamp=${project_timestamp}" >> "$GITHUB_OUTPUT"
	echo "release_type=${file_type}" >> "$GITHUB_OUTPUT"
fi

# Bare carriage-return character.
carriage_return=$( printf "\r" )

# Returns 0 if $1 matches one of the colon-separated patterns in $2.
match_pattern() {
	local _mp_file="$1"
	local _mp_list="$2:"
	local _mp_pattern
	while [ -n "$_mp_list" ]; do
		_mp_pattern=${_mp_list%%:*}
		_mp_list=${_mp_list#*:}
		# shellcheck disable=SC2254
		case $_mp_file in
			$_mp_pattern)
				return 0
				;;
		esac
	done
	return 1
}


# Simple .pkgmeta YAML processor.
declare -A yaml_bool=( ["yes"]="yes" ["true"]="yes" ["on"]="yes" ["false"]="no" ["off"]="no" ["no"]="no" )
yaml_keyvalue() {
	yaml_key=${1%%:*}
	yaml_value=${1#"$yaml_key":}
	yaml_value=${yaml_value#"${yaml_value%%[! ]*}"} # trim leading whitespace
	if [[ -n "$yaml_value" && -n "${yaml_bool[${yaml_value,,}]}" ]]; then # normalize booleans
		yaml_value="${yaml_bool[$yaml_value]}"
	fi
	yaml_value=${yaml_value#[\'\"]} # trim leading quotes
	yaml_value=${yaml_value%[\'\"]} # trim trailing quotes
}

yaml_listitem() {
	yaml_item=${1#-}
	yaml_item=${yaml_item#"${yaml_item%%[! ]*}"} # trim leading whitespace
	yaml_item=${yaml_item#[\'\"]} # trim leading quotes
	yaml_item=${yaml_item%[\'\"]} # trim trailing quotes
}

###
### Process .pkgmeta to set variables used later in the script.
###

if [ -z "$pkgmeta_file" ]; then
	pkgmeta_file="$topdir/.pkgmeta"
	# CurseForge allows this so check for it
	if [ ! -f "$pkgmeta_file" ] && [ -f "$topdir/pkgmeta.yaml" ]; then
		pkgmeta_file="$topdir/pkgmeta.yaml"
	fi
fi

# Variables set via .pkgmeta.
package=
project=
manual_changelog=
changelog=
changelog_markup="text"
enable_nolib_creation=
ignore=
license=
unchanged=
zip_root_dirs=()
nolib_exclude=
wowi_gen_changelog="true"
wowi_archive="true"
wowi_convert_changelog="true"
declare -A relations=()

parse_ignore() {
	pkgmeta="$1"    # full path to .pkgmeta
	copy_path="$2"  # the post-copy base path to match
	sub_path="$3"   # only includes matches in this path

	[ -f "$pkgmeta" ] || return 1

	check_path="$topdir/" # paths are relative to the topdir
	if [ -n "$copy_path" ]; then
		check_path=$( dirname "$pkgmeta" )"/"
		copy_path="$copy_path/"
	fi
	if [[ -n $sub_path && $sub_path != *"/" ]]; then
		sub_path="$sub_path/"
	fi

	yaml_eof=
	while [ -z "$yaml_eof" ]; do
		IFS='' read -r yaml_line || yaml_eof="true"
		# Skip commented out lines.
		if [[ $yaml_line =~ ^[[:space:]]*\# ]]; then
			continue
		fi
		# Strip any trailing CR character.
		yaml_line="${yaml_line%"$carriage_return"}"

		case $yaml_line in
			[!\ ]*:*)
				# Split $yaml_line into a $yaml_key, $yaml_value pair.
				yaml_keyvalue "$yaml_line"
				# Set the $pkgmeta_phase for stateful processing.
				pkgmeta_phase="$yaml_key"
				;;
			[\ ]*"- "*)
				yaml_line="${yaml_line#"${yaml_line%%[! ]*}"}" # trim leading whitespace
				# Get the YAML list item.
				yaml_listitem "$yaml_line"
				if [[ "$pkgmeta_phase" == "ignore" || "$pkgmeta_phase" == "plain-copy" ]] && [[ $yaml_item == "$sub_path"* ]]; then
					yaml_item=${yaml_item%"/*"} # trim dir glob
					pattern=${yaml_item#$sub_path} # match relative to sub_path
					if [ -d "$check_path$yaml_item" ]; then
						pattern="$copy_path$pattern/*"
					elif [ ! -f "$copy_path$yaml_item" ]; then
						# doesn't exist so match both a file and a path
						pattern="$copy_path$pattern:$copy_path$pattern/*"
					else
						pattern="$copy_path$pattern"
					fi
					if [[ "$pkgmeta_phase" == "ignore" ]]; then
						if [ -z "$ignore" ]; then
							ignore="$pattern"
						else
							ignore="$ignore:$pattern"
						fi
					elif [[ "$pkgmeta_phase" == "plain-copy" ]]; then
						if [ -z "$unchanged" ]; then
							unchanged="$pattern"
						else
							unchanged="$unchanged:$pattern"
						fi
					fi
				fi
				;;
		esac
	done < "$pkgmeta"
}

if [ -f "$pkgmeta_file" ]; then
	if grep -q $'^[ ]*\t\+[[:blank:]]*[[:graph:]]' "$pkgmeta_file"; then
		# Try to cut down on some troubleshooting pain.
		echo "ERROR! Your pkgmeta file contains a leading tab. Only spaces are allowed for indentation in YAML files." >&2
		grep -n $'^[ ]*\t\+[[:blank:]]*[[:graph:]]' "$pkgmeta_file" | sed $'s/\t/^I/g'
		exit 1
	fi

	yaml_eof=
	while [ -z "$yaml_eof" ]; do
		IFS='' read -r yaml_line || yaml_eof="true"
		# Skip commented out lines.
		if [[ $yaml_line =~ ^[[:space:]]*\# ]]; then
			continue
		fi
		# Strip any trailing CR character.
		yaml_line="${yaml_line%"$carriage_return"}"

		case $yaml_line in
			[!\ ]*:*)
				# Split $yaml_line into a $yaml_key, $yaml_value pair.
				yaml_keyvalue "$yaml_line"
				# Set the $pkgmeta_phase for stateful processing.
				pkgmeta_phase="$yaml_key"

				case $yaml_key in
					enable-nolib-creation)
						if [ "$yaml_value" = "yes" ]; then
							enable_nolib_creation="true"
						fi
						;;
					enable-toc-creation)
						if [ "$yaml_value" = "yes" ]; then
							split="true"
						fi
						;;
					license-output)
						license=$yaml_value
						;;
					manual-changelog)
						changelog="$yaml_value"
						manual_changelog="true"
						;;
					changelog-title)
						project="$yaml_value"
						;;
					package-as)
						package="$yaml_value"
						;;
					wowi-create-changelog)
						if [ "$yaml_value" = "no" ]; then
							wowi_gen_changelog=
						fi
						;;
					wowi-convert-changelog)
						if [ "$yaml_value" = "no" ]; then
							wowi_convert_changelog=
						fi
						;;
					wowi-archive-previous)
						if [ "$yaml_value" = "no" ]; then
							wowi_archive=
						fi
						;;
				esac
				;;
			" "*)
				yaml_line=${yaml_line#"${yaml_line%%[! ]*}"} # trim leading whitespace
				case $yaml_line in
					"- "*)
						# Get the YAML list item.
						yaml_listitem "$yaml_line"
						case $pkgmeta_phase in
							tools-used)
								relations["${yaml_item,,}"]="tool"
								;;
							required-dependencies)
								relations["${yaml_item,,}"]="requiredDependency"
								;;
							optional-dependencies)
								relations["${yaml_item,,}"]="optionalDependency"
								;;
							embedded-libraries)
								relations["${yaml_item,,}"]="embeddedLibrary"
								;;
						esac
						;;
					*:*)
						# Split $yaml_line into a $yaml_key, $yaml_value pair.
						yaml_keyvalue "$yaml_line"
						case $pkgmeta_phase in
							manual-changelog)
								case $yaml_key in
									filename)
										changelog="$yaml_value"
										manual_changelog="true"
										;;
									markup-type)
										if [ "$yaml_value" = "markdown" ] || [ "$yaml_value" = "html" ]; then
											changelog_markup="$yaml_value"
										else
											changelog_markup="text"
										fi
										;;
								esac
								;;
							move-folders)
								# Save project root directories
								if [[ $yaml_value != *"/"* ]]; then
									_mf_path="${yaml_key#*/}" # strip the package name
									toc_root_paths["$topdir/$_mf_path"]="$yaml_value"
								fi
								;;
						esac
						;;
				esac
				;;
		esac
	done < "$pkgmeta_file"
fi

# Add untracked/ignored files to the ignore list

vcs_addignore() {
	local _ignored_path="$1"
	if [[ -d "$topdir/$_ignored_path" ]]; then
		_ignored_path="$_ignored_path*"
	fi
	# Don't ignore a manual changelog generated for the build
	if [[ -z $changelog || $_ignored_path != "$changelog" ]]; then
		if [[ -z "$ignore" ]]; then
			ignore="$_ignored_path"
		else
			ignore="$ignore:$_ignored_path"
		fi
	fi
}

OLDIFS=$IFS
IFS=$'\n'
if [ "$repository_type" = "git" ]; then
	for _vcs_ignore in $( git -C "$topdir" ls-files --others --directory ); do
		vcs_addignore "$_vcs_ignore"
	done
elif [ "$repository_type" = "svn" ]; then
	for _vcs_ignore in $( cd "$topdir" && svn status --no-ignore --ignore-externals | awk '/^[?IX]/ { print $2 }' ); do
		vcs_addignore "${_vcs_ignore//\\//}"
	done
elif [ "$repository_type" = "hg" ]; then
	for _vcs_ignore in $( hg --cwd "$topdir" status --ignored --unknown --no-status ); do
		vcs_addignore "$_vcs_ignore"
	done
fi
IFS=$OLDIFS


# Add .pkgmeta ignored files to the ignore list
parse_ignore "$pkgmeta_file"

###
### Process TOC file
###

set_info_toc_interface() {
	local toc_path="$1"
	local package_name="$2"

	si_game_type_interface=()
	si_game_type_interface_all=()
	si_game_root_interface=
	[[ -z $package_name ]] && return 0

	local toc_name=${toc_path##*/}

	local toc_file toc_version toc_game_type
	toc_file=$(
		# Remove BOM and CR and apply some non-version related TOC filters
		[[ $file_type != "alpha" ]] && _tf_alpha="true"
		sed -e $'1s/^\xEF\xBB\xBF//' -e $'s/\r//g' "$toc_path" | toc_filter alpha ${_tf_alpha:+true} | toc_filter debug true
	)

	toc_version=$( awk -F: '/^## Interface:/ { gsub(/[ \t]/, "", $2); print $2; exit }' <<< "$toc_file" )
	if [[ -n $toc_version ]]; then
		local toc_version_game_type
		IFS=',' read -ra V <<< "$toc_version"
		toc_to_type "${V[0]}" "toc_game_type"
		for i in "${V[@]}"; do
			toc_to_type "$i" "toc_version_game_type"

			if [[ -n ${si_game_type_interface_all[$toc_version_game_type]} ]]; then
				si_game_type_interface_all[$toc_version_game_type]="${si_game_type_interface_all[$toc_version_game_type]}:$i"
			else
				si_game_type_interface_all[$toc_version_game_type]="$i"
			fi

			# Are the interface values all for one game type?
			if [[ -n $toc_game_type && $toc_game_type != "$toc_version_game_type" ]]; then
				toc_game_type=
			fi
		done

		# Splitting needs the fallback toc to be game typed, so make sure we're not mixing strategies
		# if [[ -n $split && -z $toc_game_type ]]; then
		# 	echo "$toc_name has multiple game type interface versions as the fallback ($toc_version) but creating TOC files is enabled." >&2
		# 	echo "Add additional \"## Interface-[Type]:\" lines for each game type TOC file to create." >&2
		# 	exit 1
		# fi

		toc_version=$( IFS=':' ; echo "${V[*]}" ) # swap delimiter
		si_game_root_interface="$toc_version"
	fi

	if [[ ${toc_name} =~ "$package_name"[-_](Mainline|Classic|Vanilla|BCC|TBC|Wrath|WOTLKC|Cata|Mists)\.toc$ ]]; then
		# Flavored, just validate the version
		if [[ -z $toc_version ]]; then
			echo "$toc_name is missing an interface version." >&2
			exit 1
		fi
		local toc_file_game_type="${game_flavor[${BASH_REMATCH[1],,}]}"
		if [[ $toc_file_game_type != "$toc_game_type" ]]; then
			if [[ $toc_file_game_type == "classic" && -z $toc_game_type ]]; then
				# New loading logic for _Classic
				IFS=':' read -ra V <<< "$toc_version"
				for i in "${V[@]}"; do
					toc_to_type "$i" "toc_file_game_type"
					if [[ $toc_file_game_type == "retail" ]]; then
						echo "$toc_name has an interface version ($i) that is not compatible with the game version \"classic\"." >&2
						exit 1
					fi
				done
			else
				echo "$toc_name has an interface version ($toc_version) that is not compatible with the game version \"${toc_file_game_type}\"." >&2
				exit 1
			fi
		fi
	else
		# Fallback
		local game_type_toc_version toc_file_game_type

		# Save the game type interface values
		for type in "${!game_flavor[@]}"; do
			game_type_toc_version=$( awk -F: 'tolower($0) ~ /^## interface-'"$type"':/ { gsub(/[ \t]/, "", $2); print $2; exit }' <<< "$toc_file" )
			if [[ -n $game_type_toc_version ]]; then
				type="${game_flavor[$type]}"
				IFS=',' read -ra V <<< "$game_type_toc_version"
				for i in "${V[@]}"; do
					toc_to_type "$i" "toc_file_game_type"
					if [[ $toc_file_game_type != "$type" ]]; then
						echo "$toc_name has an interface version ($i) that is not compatible with \"Interface-${type^}\"." >&2
						exit 1
					fi
				done
				game_type_toc_version=$( IFS=':' ; echo "${V[*]}" ) # swap delimiter
				si_game_type_interface[$type]="$game_type_toc_version"
				si_game_type_interface_all[$type]="$game_type_toc_version"
			fi
		done

		# Use the game type if set, otherwise default to retail
		game_type_toc_version="${si_game_type_interface_all[${game_type:-retail}]}"
		# No "Interface:" value or game type doesn't match, try to use the "Interface-Type:" value
		if [[ -z $toc_version ]] || [[ -n $game_type && -n $game_type_toc_version && $game_type_toc_version != "$toc_version" ]]; then
			toc_version="$game_type_toc_version"
			toc_game_type="${game_type:-retail}"
		fi

		# Check @non-@ blocks for an interface matching the game type (DEPRECATED, remove this in v3)
		if [[ -z $toc_version ]] || [[ -n $game_type && $toc_game_type != "$game_type" ]]; then
			toc_game_type="$game_type"
			local game_type_toc_prefix
			case $toc_game_type in
				classic) game_type_toc_prefix="11[345]" ;;
				bcc) game_type_toc_prefix="20" ;;
				wrath) game_type_toc_prefix="30" ;;
				cata) game_type_toc_prefix="40" ;;
				mists) game_type_toc_prefix="50" ;;
				*) game_type_toc_prefix=
			esac
			if [[ -n $game_type_toc_prefix ]]; then
				toc_version=$( sed -n '/@non-[-a-z]*@/,/@end-non-[-a-z]*@/{//b;p}' <<< "$toc_file" | awk -F: '/#[ \t]*## Interface:[ \t]*('"$game_type_toc_prefix"')/ { gsub(/[ \t]/, "", $2); print $2; exit }' )
				IFS=',' read -ra V <<< "$toc_version"
				for i in "${V[@]}"; do
					toc_to_type "$i" "toc_file_game_type"
					if [[ $toc_file_game_type != "$toc_game_type" ]]; then
						echo "$toc_name has an interface version ($i) that is not compatible with the game version \"${game_flavor[$toc_game_type]}\"." >&2
						exit 1
					fi
				done
				toc_version=$( IFS=':' ; echo "${V[*]}" ) # swap delimiter

				# This becomes the actual interface version after replacements
				si_game_root_interface="$toc_version"
				si_game_type_interface_all[$toc_game_type]="$toc_version"
			fi
		fi

		# End of the line
		if [[ -z $toc_version ]]; then
			if [[ -z $toc_game_type ]]; then
				echo "$toc_name is missing an interface version." >&2
			else
				echo "$toc_name has an interface version that is not compatible with the game version \"$toc_game_type\" or was not found." >&2
			fi
			exit 1
		fi
	fi
}

set_toc_project_info() {
	local toc_path="$1"
	# Get the title of the addon for the changelog
	if [ -z "$project" ]; then
		project=$( sed -e $'1s/^\xEF\xBB\xBF//' -e $'s/\r//g' "$toc_path" | awk '/^## Title:/ { print $0; exit }' | sed -e 's/|c[0-9A-Fa-f]\{8\}//g' -e 's/|r//g' -e 's/|T[^|]*|t//g' -e 's/## Title[[:space:]]*:[[:space:]]*\(.*\)/\1/' -e 's/[[:space:]]*$//' )
	fi
	# Get project IDs for uploading
	if [ -z "$slug" ]; then
		slug=$( sed -e $'1s/^\xEF\xBB\xBF//' -e $'s/\r//g' "$toc_path" | awk -F: '/^## X-Curse-Project-ID:/ { gsub(/[ \t]/, "", $2); print $2; exit }' )
	fi
	if [ -z "$addonid" ]; then
		addonid=$( sed -e $'1s/^\xEF\xBB\xBF//' -e $'s/\r//g' "$toc_path" | awk -F: '/^## X-WoWI-ID:/ { gsub(/[ \t]/, "", $2); print $2; exit }' )
	fi
	if [ -z "$wagoid" ]; then
		wagoid=$( sed -e $'1s/^\xEF\xBB\xBF//' -e $'s/\r//g' "$toc_path" | awk -F: '/^## X-Wago-ID:/ { gsub(/[ \t]/, "", $2); print $2; exit }' )
	fi
}

set_build_version() {
	if [[ -z $game_version ]]; then
		local toc_version toc_game_type path_interface path_version
		for path in "${toc_paths[@]}"; do
			if [[ -z "$split" && -z "$game_type" ]]; then
				# no split and no game type means we should use the root interface value
				toc_version="${toc_root_interface[$path]}"
			else
				toc_version="${toc_interfaces[$path]}"
			fi
			IFS=':' read -ra V <<< "$toc_version"
			for i in "${V[@]}"; do
				toc_to_type "$i" "toc_game_type"
				# add the version for every root addon
				if [[ -z $game_type || $game_type == "$toc_game_type" ]]; then
					path_interface="$i"
					path_version=$( printf "%d.%d.%d" $(( 10#${i:0: -4} )) $(( 10#${i: -4:2} )) $(( 10#${i: -2:2} )) )
					if [[ -n ${game_type_interface[$toc_game_type]} ]]; then
						if [[ ":${game_type_interface[$toc_game_type]}:" != *":$path_interface:"* ]]; then
							game_type_interface[$toc_game_type]="${game_type_interface[$toc_game_type]}:$path_interface"
							game_type_version[$toc_game_type]="${game_type_version[$toc_game_type]}:$path_version"
						fi
					else
						game_type_interface[$toc_game_type]="$path_interface"
						game_type_version[$toc_game_type]="$path_version"
					fi
				fi
			done
		done
	fi

	# Set the game versions shown in the summary
	game_version=$(
		if [[ -n $game_type ]]; then
			readarray -t sorted < <( printf '%s\n' "${game_type_version[$game_type]//:/$'\n'}" | sort -Vr )
		else
			readarray -t sorted < <( printf '%s\n' "${game_type_version[@]//:/$'\n'}" | sort -Vr )
		fi
		IFS=',' ; echo "${sorted[*]}"
	)

	# Set the game type when we only have one game version
	if [[ -z $game_type && ${#game_type_version[@]} -eq 1 ]]; then
		game_type="${!game_type_version[*]}"
	fi
}

# Set the package name from a TOC file name
if [[ -z "$package" ]]; then
	# shellcheck disable=SC2035
	package=$( cd "$topdir" && find *.toc -maxdepth 0 2>/dev/null | sort -dr | head -n1 )
	if [[ -z "$package" ]]; then
		echo "Could not find an addon TOC file. In another directory? Set 'package-as' in .pkgmeta" >&2
		exit 1
	fi
	package=${package%.toc}
	if [[ $package =~ ^(.*)([-_](Mainline|Classic|Vanilla|BCC|TBC|Wrath|WOTLKC|Cata|Mists))$ ]]; then
		echo "Ambiguous addon name. No fallback TOC file or addon name includes an expansion suffix (${BASH_REMATCH[2]}). Set 'package-as' in .pkgmeta" >&2
		exit 1
	fi
fi

# Parse the project root TOC files for info first
for toc_path in "$topdir/$package"{,-Mainline,_Mainline,-Classic,_Classic,-Vanilla,_Vanilla,-BCC,_BCC,-TBC,_TBC,-Wrath,_Wrath,-WOTLKC,_WOTLKC,-Cata,_Cata,-Mists,_Mists}.toc; do
	if [[ -f "$toc_path" ]]; then
		set_toc_project_info "$toc_path"
		toc_paths+=("$toc_path")
		toc_root_paths["$topdir"]="$package"
	fi
done
# Try parsing the project addon in move-folders for info next
for path in "${!toc_root_paths[@]}"; do
	if [[ ${toc_root_paths[$path]} == "$package" && $path != "$topdir" ]]; then
		for toc_path in "$path/$package"{,-Mainline,_Mainline,-Classic,_Classic,-Vanilla,_Vanilla,-BCC,_BCC,-TBC,_TBC,-Wrath,_Wrath,-WOTLKC,_WOTLKC,-Cata,_Cata,-Mists,_Mists}.toc; do
			if [[ -f "$toc_path" ]]; then
				set_toc_project_info "$toc_path"
			fi
		done
	fi
done

# Parse project TOC files
for path in "${!toc_root_paths[@]}"; do
	for toc_path in "$path/${toc_root_paths[$path]}"{,-Mainline,_Mainline,-Classic,_Classic,-Vanilla,_Vanilla,-BCC,_BCC,-TBC,_TBC,-Wrath,_Wrath,-WOTLKC,_WOTLKC,-Cata,_Cata,-Mists,_Mists}.toc; do
		if [[ -f "$toc_path" ]]; then
			set_toc_project_info "$toc_path"
			set_info_toc_interface "$toc_path" "${toc_root_paths[$path]}"
			toc_root_interface[$toc_path]="$si_game_root_interface"
			toc_interfaces[$toc_path]=$( IFS=':' ; echo "${si_game_type_interface_all[*]}" )
			if [[ " ${toc_paths[*]} " != *" $toc_path "* ]]; then
				toc_paths+=("$toc_path")
			fi
		fi
	done
done

if [[ ${#toc_interfaces[@]} -eq 0 ]]; then
	echo "Could not find an addon TOC file. In another directory? Make sure it matches the 'package-as' in .pkgmeta" >&2
	exit 1
fi

if [[ -n "$split" ]]; then
	if [[ "${toc_interfaces[*]}" != *":"* ]]; then
		echo "Creating TOC files is enabled but there is only one TOC interface version per file?" >&2
		for path in "${toc_paths[@]}"; do
			[[ -n ${toc_interfaces[$path]} ]] && echo "  ${path##$topdir/} [${toc_interfaces[$path]}]" >&2
		done
		exit 1
	fi
fi

set_build_version

if [[ -z "$game_version" ]]; then
	echo "There was a problem setting the build version. Do you have a base \"# Interface:\" line in your TOC files?" >&2
	exit 1
fi

# Unset project ids if they are set to 0
[ "$slug" = "0" ] && slug=
[ "$addonid" = "0" ] && addonid=
[ "$wagoid" = "0" ] && wagoid=

echo "Packaging $package"
if [ -n "$project_version" ]; then
	echo "Current version: $project_version"
fi
if [ -n "$previous_version" ]; then
	echo "Previous version: $previous_version"
fi
(
	if [[ -n $game_type ]]; then
		[[ $game_type == "retail" ]] && version="retail " || version="non-retail version-${game_type} "
	elif [[ ${#game_type_version[@]} -gt 1 ]]; then
		version="multi-version "
	fi
	[ "$file_type" = "alpha" ] && alpha="alpha" || alpha="non-alpha"
	echo "Build type: ${version}${alpha} non-debug${nolib:+ nolib}"
	echo "Game version: ${game_version}"
	echo
)
if [[ "$slug" =~ ^[0-9]+$ ]]; then
	project_site="https://wow.curseforge.com"
	echo "CurseForge ID: $slug${cf_token:+ [token set]}"
fi
if [ -n "$addonid" ]; then
	echo "WoWInterface ID: $addonid${wowi_token:+ [token set]}"
fi
if [ -n "$wagoid" ]; then
	echo "Wago ID: $wagoid${wago_token:+ [token set]}"
fi
if [ -n "$project_github_slug" ]; then
	echo "GitHub: $project_github_slug${github_token:+ [token set]}"
fi
if [ -n "$project_site" ] || [ -n "$addonid" ] || [ -n "$wagoid" ] || [ -n "$project_github_slug" ]; then
	echo
fi
echo "Checkout directory: $topdir"
echo "Release directory: $releasedir"
echo

# Set $pkgdir to the path of the package directory inside $releasedir.
pkgdir="$releasedir/$package"
if [ -d "$pkgdir" ] && [ -z "$overwrite" ]; then
	#echo "Removing previous package directory: $pkgdir"
	rm -fr "$pkgdir"
fi
if [ ! -d "$pkgdir" ]; then
	mkdir -p "$pkgdir"
fi

# Set the contents of the addon zipfile.
zip_root_dirs+=("$package")

###
### Create filters for pass-through processing of files to replace repository keywords.
###

# Filter for simple repository keyword replacement.
vcs_filter() {
	sed \
		-e "s/@project-revision@/$si_project_revision/g" \
		-e "s/@project-hash@/$si_project_hash/g" \
		-e "s/@project-abbreviated-hash@/$si_project_abbreviated_hash/g" \
		-e "s/@project-author@/$( escape_substr "$si_project_author" )/g" \
		-e "s/@project-date-iso@/$si_project_date_iso/g" \
		-e "s/@project-date-integer@/$si_project_date_integer/g" \
		-e "s/@project-timestamp@/$si_project_timestamp/g" \
		-e "s/@project-version@/$( escape_substr "$si_project_version" )/g" \
		-e "s/@file-revision@/$si_file_revision/g" \
		-e "s/@file-hash@/$si_file_hash/g" \
		-e "s/@file-abbreviated-hash@/$si_file_abbreviated_hash/g" \
		-e "s/@file-author@/$( escape_substr "$si_file_author" )/g" \
		-e "s/@file-date-iso@/$si_file_date_iso/g" \
		-e "s/@file-date-integer@/$si_file_date_integer/g" \
		-e "s/@file-timestamp@/$si_file_timestamp/g" \
		-e "s/@build-date@/$si_build_date/g" \
		-e "s/@build-date-iso@/$si_build_date_iso/g" \
		-e "s/@build-date-integer@/$si_build_date_integer/g" \
		-e "s/@build-timestamp@/$si_build_timestamp/g"
}

# Find URL of localization api.
set_localization_url() {
	localization_url=
	if [ -n "$slug" ] && [ -n "$cf_token" ] && [ -n "$project_site" ]; then
		localization_url="${project_site}/api/projects/$slug/localization/export"
	fi
	if [ -z "$localization_url" ] && find "$topdir" -path '*/.*' -prune -o -name "*.lua" -print0 | xargs -0 grep -q "@localization"; then
		echo "Skipping localization! Missing CurseForge API token and/or project id is invalid."
		echo
	fi
}

# Filter to handle @localization@ repository keyword replacement.
# https://authors.curseforge.com/knowledge-base/projects/531-localization-substitutions/
declare -A unlocalized_values=( ["english"]="ShowPrimary" ["comment"]="ShowPrimaryAsComment" ["blank"]="ShowBlankAsComment" ["ignore"]="Ignore" )
localization_filter() {
	_ul_eof=
	while [ -z "$_ul_eof" ]; do
		IFS='' read -r _ul_line || _ul_eof="true"
		# Strip any trailing CR character.
		_ul_line=${_ul_line%$carriage_return}
		case $_ul_line in
			*@localization\(*\)@*)
				_ul_lang=
				_ul_namespace=
				_ul_singlekey=
				_ul_tablename="L"
				# Get the prefix of the line before the comment.
				_ul_prefix=${_ul_line%%@localization(*}
				_ul_prefix=${_ul_prefix%%--*}
				# Strip everything but the localization parameters.
				_ul_params=${_ul_line#*@localization(}
				_ul_params=${_ul_params%)@}
				# Sanitize the params a bit. (namespaces are restricted to [a-zA-Z0-9_], separated by [./:])
				_ul_params=${_ul_params// /}
				_ul_params=${_ul_params//,/, }
				# Pull the locale language first (mainly for warnings).
				_ul_lang="enUS"
				if [[ $_ul_params == *"locale=\""* ]]; then
					_ul_lang=${_ul_params##*locale=\"}
					_ul_lang=${_ul_lang:0:4}
					_ul_lang=${_ul_lang%%\"*}
				else
					echo "    Warning! No locale set, using enUS." >&3
				fi
				# Generate a URL parameter string from the localization parameters.
				# https://authors.curseforge.com/knowledge-base/projects/529-api
				_ul_url_params=""
				# shellcheck disable=SC2086
				set -- ${_ul_params}
				for _ul_param; do
					_ul_key=${_ul_param%%=*}
					_ul_value=${_ul_param#*=}
					_ul_value=${_ul_value%,*}
					_ul_value=${_ul_value#*\"}
					_ul_value=${_ul_value%\"*}
					case ${_ul_key} in
						escape-non-ascii)
							if [ "$_ul_value" = "true" ]; then
								_ul_url_params="${_ul_url_params}&escape-non-ascii-characters=true"
							fi
							;;
						format)
							if [ "$_ul_value" = "lua_table" ]; then
								_ul_url_params="${_ul_url_params}&export-type=Table"
							fi
							;;
						handle-unlocalized)
							if [ "$_ul_value" != "english" ] && [ -n "${unlocalized_values[$_ul_value]}" ]; then
								_ul_url_params="${_ul_url_params}&unlocalized=${unlocalized_values[$_ul_value]}"
							fi
							;;
						handle-subnamespaces)
							if [ "$_ul_value" = "concat" ]; then # concat with /
								_ul_url_params="${_ul_url_params}&concatenante-subnamespaces=true"
							elif [ "$_ul_value" = "subtable" ]; then
								echo "    ($_ul_lang) Warning! ${_ul_key}=\"${_ul_value}\" is not supported. Include each full subnamespace, comma delimited." >&3
							fi
							;;
						key)
							# _ul_params was stripped of spaces, so reparse the line for the key
							_ul_singlekey=${_ul_line#*@localization(}
							_ul_singlekey=${_ul_singlekey#*key=\"}
							_ul_singlekey=${_ul_singlekey%%\",*}
							_ul_singlekey=${_ul_singlekey%%\")@*}
							;;
						locale)
							_ul_lang=$_ul_value
							;;
						namespace)
							# reparse to get all namespaces if multiple
							_ul_namespace=${_ul_params##*namespace=\"}
							_ul_namespace=${_ul_namespace%%\"*}
							_ul_namespace=${_ul_namespace//, /,}
							_ul_url_params="${_ul_url_params}&namespaces=${_ul_namespace}"
							_ul_namespace="/${_ul_namespace}"
							;;
						namespace-delimiter)
							if [ "$_ul_value" != "/" ]; then
								echo "    ($_ul_lang) Warning! ${_ul_key}=\"${_ul_value}\" is not supported." >&3
							fi
							;;
						prefix-values)
							echo "    ($_ul_lang) Warning! \"${_ul_key}\" is not supported." >&3
							;;
						same-key-is-true)
							if [ "$_ul_value" = "true" ]; then
								_ul_url_params="${_ul_url_params}&true-if-value-equals-key=true"
							fi
							;;
						table-name)
							if [ "$_ul_value" != "L" ]; then
								_ul_tablename="$_ul_value"
								_ul_url_params="${_ul_url_params}&table-name=${_ul_value}"
							fi
							;;
					esac
				done

				if [ -z "$_cdt_localization" ] || [ -z "$localization_url" ]; then
					echo "    Skipping localization (${_ul_lang}${_ul_namespace})" >&3

					# If the line isn't a TOC entry, print anything before the keyword.
					if [[ $_ul_line != "## "* ]]; then
						if [ -n "$_ul_eof" ]; then
							echo -n "$_ul_prefix"
						else
							echo "$_ul_prefix"
						fi
					fi
				else
					_ul_url="${localization_url}?lang=${_ul_lang}${_ul_url_params}"
					echo "    Adding ${_ul_lang}${_ul_namespace}" >&3

					if [ -z "$_ul_singlekey" ]; then
						# Write text that preceded the substitution.
						echo -n "$_ul_prefix"

						# Fetch the localization data, but don't output anything if there is an error.
						curl -s -H "x-api-token: $cf_token" "${_ul_url}" | awk -v url="$_ul_url" '/^{"error/ { o="    \033[01;31mError! "$0"\033[0m\n           "url; print o >"/dev/fd/3"; exit 1 } /<!DOCTYPE/ { print "    \033[01;31mError! Invalid output\033[0m\n           "url >"/dev/fd/3"; exit 1 } /^<html>/ { print "    \033[01;31mError! Invalid output\033[0m\n           "url >"/dev/fd/3"; exit 1 } /^'"$_ul_tablename"' = '"$_ul_tablename"' or \{\}/ { next } { print }' || exit 1

						# Insert a trailing blank line to match CF packager.
						if [ -z "$_ul_eof" ]; then
							echo ""
						fi
					else
						# Parse out a single phrase. This is kind of expensive, but caching would be way too much effort to optimize for what is basically an edge case.
						_ul_value=$( curl -s -H "x-api-token: $cf_token" "${_ul_url}" | awk -v url="$_ul_url" '/^{"error/ { o="    \033[01;31mError! "$0"\033[0m\n           "url; print o >"/dev/fd/3"; exit 1 } /<!DOCTYPE/ { print "    \033[01;31mError! Invalid output\033[0m\n           "url >"/dev/fd/3"; exit 1 } /^<html>/ { print "    \033[01;31mError! Invalid output\033[0m\n           "url >"/dev/fd/3"; exit 1 } { print }' | sed -n '/L\["'"$_ul_singlekey"'"\]/p' | sed 's/^.* = "\(.*\)"/\1/' )
						if [ -n "$_ul_value" ] && [ "$_ul_value" != "$_ul_singlekey" ]; then
							# The result is different from the base value so print out the line.
							echo "${_ul_prefix}${_ul_value}${_ul_line##*)@}"
						fi
					fi
				fi
				;;
			*)
				if [ -n "$_ul_eof" ]; then
					echo -n "$_ul_line"
				else
					echo "$_ul_line"
				fi
		esac
	done
}

lua_filter() {
	local keyword="$1"
	local width
	case $keyword in
		alpha) width="=" ;;
		debug) width="==" ;;
		retail|version-*) width="====" ;;
		*) width="==="
	esac
	sed \
		-e "s/--@${keyword}@/--[${width}[@${keyword}@/g" \
		-e "s/--@end-${keyword}@/--@end-${keyword}@]${width}]/g" \
		-e "s/--\[===\[@non-${keyword}@/--@non-${keyword}@/g" \
		-e "s/--@end-non-${keyword}@\]===\]/--@end-non-${keyword}@/g"
}

toc_interface_filter() {
	local toc_version="${1//:/, }"
	local current_toc_version="${2//:/, }"
	# TOC version isn't what is set in the TOC file
	if [[ -n "$toc_version" && "$current_toc_version" != "$toc_version" ]]; then
		# Always remove BOM so ^ works
		if [ -n "$current_toc_version" ]; then # rewrite
			sed -e $'1s/^\xEF\xBB\xBF//' -e 's/^## Interface:.*$/## Interface: '"$toc_version"'/' -e '/^## Interface-/d'
		else # add
			sed -e $'1s/^\xEF\xBB\xBF//' -e '1i\
## Interface: '"$toc_version" -e '/^## Interface-/d'
		fi
		if [[ -z "$split" ]]; then
			echo "    Set Interface to ${toc_version}" >&3
		fi
	else # cleanup
		sed -e $'1s/^\xEF\xBB\xBF//' -e '/^## Interface-/d'
	fi
}

xml_filter() {
	sed \
		-e "s/<!--@$1@-->/<!--@$1@/g" \
		-e "s/<!--@end-$1@-->/@end-$1@-->/g" \
		-e "s/<!--@non-$1@/<!--@non-$1@-->/g" \
		-e "s/@end-non-$1@-->/<!--@end-non-$1@-->/g"
}

do_not_package_filter() {
	case $1 in
		lua) sed '/--@do-not-package@/,/--@end-do-not-package@/d' ;;
		toc) sed '/#@do-not-package@/,/#@end-do-not-package@/d' ;;
		xml) sed '/<!--@do-not-package@-->/,/<!--@end-do-not-package@-->/d' ;;
	esac
}

line_ending_filter() {
	local _lef_eof _lef_line
	while [ -z "$_lef_eof" ]; do
		IFS='' read -r _lef_line || _lef_eof="true"
		# Strip any trailing CR character.
		_lef_line=${_lef_line%$carriage_return}
		if [ -n "$_lef_eof" ]; then
			# Preserve EOF not preceded by newlines.
			echo -n "$_lef_line"
		else
			case $line_ending in
				dos) printf "%s\r\n" "$_lef_line" ;; # Terminate lines with CR LF.
				unix) printf "%s\n" "$_lef_line"  ;; # Terminate lines with LF.
			esac
		fi
	done
}

###
### Copy files from the working directory into the package directory.
###

# Copy of the contents of the source directory into the destination directory.
# Dotfiles and any files matching the ignore pattern are skipped.  Copied files
# are subject to repository keyword replacement.
#
copy_directory_tree() {
	_cdt_alpha=
	_cdt_debug=
	_cdt_ignored_patterns=
	_cdt_localization=
	_cdt_nolib=
	_cdt_do_not_package=
	_cdt_unchanged_patterns=
	_cdt_gametype=
	_cdt_external=
	_cdt_split=
	OPTIND=1
	while getopts :adi:lnpu:g:eS _cdt_opt "$@"; do
		# shellcheck disable=SC2220
		case $_cdt_opt in
			a)	_cdt_alpha="true" ;;
			d)	_cdt_debug="true" ;;
			i)	_cdt_ignored_patterns=$OPTARG ;;
			l)	_cdt_localization="true"
					set_localization_url
					;;
			n)	_cdt_nolib="true" ;;
			p)	_cdt_do_not_package="true" ;;
			u)	_cdt_unchanged_patterns=$OPTARG ;;
			g)	_cdt_gametype=$OPTARG ;;
			e)	_cdt_external="true" ;;
			S)	_cdt_split="true" ;;
		esac
	done
	shift $((OPTIND - 1))
	_cdt_srcdir=$1
	_cdt_destdir=$2

	if [ -z "$_cdt_external" ]; then
		start_group "Copying files into ${_cdt_destdir#$topdir/}:" "copy"
	else # don't nest groups
		echo "Copying files into ${_cdt_destdir#$topdir/}:"
	fi
	if [ ! -d "$_cdt_destdir" ]; then
		mkdir -p "$_cdt_destdir"
	fi

	# Create a "find" command to list all of the files in the current directory, minus any ones we need to prune.
	_cdt_find_cmd="find ."
	# Prune everything that begins with a dot except for the current directory ".".
	_cdt_find_cmd+=" \( -name \".*\" -a \! -name \".\" \) -prune"
	# Prune the destination directory if it is a subdirectory of the source directory.
	_cdt_dest_subdir=${_cdt_destdir#${_cdt_srcdir}/}
	case $_cdt_dest_subdir in
		/*) ;;
		*) _cdt_find_cmd+=" -o -path \"./$_cdt_dest_subdir\" -prune" ;;
	esac
	# Print the filename, but suppress the current directory ".".
	_cdt_find_cmd+=" -o \! -name \".\" -print"

	local file
	while read -r file; do # <( cd "$_cdt_srcdir" && eval "$_cdt_find_cmd" )
		file=${file#./}
		_cdt_source_file="$_cdt_srcdir/$file"
		if [ -f "$_cdt_source_file" ]; then
			_cdt_skip_copy=
			_cdt_only_copy=
			# Prefix external files with the relative pkgdir path
			_cdt_check_file=$file
			if [ -n "${_cdt_destdir#$pkgdir}" ]; then
				_cdt_check_file="${_cdt_destdir#$pkgdir/}/$file"
			fi
			# Skip files matching the colon-separated "ignored" shell wildcard patterns.
			if match_pattern "$_cdt_check_file" "$_cdt_ignored_patterns"; then
				_cdt_skip_copy="true"
			fi
			# Never skip files that match the colon-separated "unchanged" shell wildcard patterns.
			if match_pattern "$_cdt_check_file" "$_cdt_unchanged_patterns"; then
				_cdt_skip_copy=
				_cdt_only_copy="true"
			fi
			# Copy unskipped files into $_cdt_destdir.
			if [ -n "$_cdt_skip_copy" ]; then
				echo "  Ignoring: $file"
			else
				_cdt_subdir=${file%/*}
				if [ "$_cdt_subdir" != "$file" ]; then
					mkdir -p "$_cdt_destdir/$_cdt_subdir"
				fi
				# Check for marked hard embedded libraries
				_cdt_external_slug=
				if [[ $_cdt_source_file == *".lua" ]] && _cdt_external_slug=$( grep -io "@curseforge-project-slug[[:blank:]]*:[[:blank:]]*[^@]\+@" "$_cdt_source_file"); then
					_cdt_external_slug="${_cdt_external_slug//[[:blank:]@]/}"
					_cdt_external_slug="${_cdt_external_slug##*:}"
					if [[ ${_cdt_external_slug,,} == "${package,,}" ]]; then
						_cdt_external_slug=
					fi
					if [[ -n $_cdt_external_slug ]]; then
						relations["${_cdt_external_slug,,}"]="embeddedLibrary"
					fi
				fi
				# Check if the file matches a pattern for keyword replacement.
				if [ -n "$_cdt_only_copy" ] || ! match_pattern "$file" "*.lua:*.md:*.toc:*.txt:*.xml"; then
					echo "  Copying: $file (unchanged)${_cdt_external_slug:+(embedded: "$_cdt_external_slug")}"
					cp "$_cdt_source_file" "$_cdt_destdir/$_cdt_subdir"
				else
					_cdt_file_gametype="$_cdt_gametype"
					# Set the filters for replacement based on file extension.
					_cdt_filters="vcs_filter"
					case $file in
						*.lua)
							[[ -n $_cdt_do_not_package ]] && _cdt_filters+="|do_not_package_filter lua"
							[[ -n $_cdt_debug ]] && _cdt_filters+="|lua_filter debug"
							[[ -n $_cdt_alpha ]] && _cdt_filters+="|lua_filter alpha"
							if [[ -n $_cdt_file_gametype ]]; then
								[[ $_cdt_file_gametype != "retail" ]] && _cdt_filters+="|lua_filter version-retail|lua_filter retail"
								[[ $_cdt_file_gametype != "classic" ]] && _cdt_filters+="|lua_filter version-classic|lua_filter version-vanilla"
								[[ $_cdt_file_gametype != "bcc" ]] && _cdt_filters+="|lua_filter version-bcc"
								[[ $_cdt_file_gametype != "wrath" ]] && _cdt_filters+="|lua_filter version-wrath"
								[[ $_cdt_file_gametype != "cata" ]] && _cdt_filters+="|lua_filter version-cata"
								[[ $_cdt_file_gametype != "mists" ]] && _cdt_filters+="|lua_filter version-mists"
							fi
							[[ -n $_cdt_localization ]] && grep -q "@localization" "$_cdt_source_file" && _cdt_filters+="|localization_filter"
							;;
						*.xml)
							[[ -n $_cdt_do_not_package ]] && _cdt_filters+="|do_not_package_filter xml"
							[[ -n $_cdt_nolib ]] && _cdt_filters+="|xml_filter no-lib-strip"
							[[ -n $_cdt_debug ]] && _cdt_filters+="|xml_filter debug"
							[[ -n $_cdt_alpha ]] && _cdt_filters+="|xml_filter alpha"
							if [[ -n $_cdt_file_gametype ]]; then
								[[ $_cdt_file_gametype != "retail" ]] && _cdt_filters+="|xml_filter version-retail|xml_filter retail"
								[[ $_cdt_file_gametype != "classic" ]] && _cdt_filters+="|xml_filter version-classic|xml_filter version-vanilla"
								[[ $_cdt_file_gametype != "bcc" ]] && _cdt_filters+="|xml_filter version-bcc"
								[[ $_cdt_file_gametype != "wrath" ]] && _cdt_filters+="|xml_filter version-wrath"
								[[ $_cdt_file_gametype != "cata" ]] && _cdt_filters+="|xml_filter version-cata"
								[[ $_cdt_file_gametype != "mists" ]] && _cdt_filters+="|xml_filter version-mists"
							fi
							;;
						*.toc)
							# We only care about processing project TOC files
							if [[ -n ${toc_interfaces["$_cdt_source_file"]} ]]; then
								# Set the interface values
								_cdt_toc_dir="${_cdt_source_file%/*}"
								set_info_toc_interface "$_cdt_source_file" "${toc_root_paths["$_cdt_toc_dir"]}"
								# Add build type filters
								_cdt_filters+="|do_not_package_filter toc"
								[ -n "$_cdt_nolib" ] && _cdt_filters+="|toc_filter no-lib-strip true" # leave the tokens in the file normally
								_cdt_filters+="|toc_filter debug ${_cdt_debug}"
								_cdt_filters+="|toc_filter alpha ${_cdt_alpha}"
								# Add game type filters, skipping if multi-version
								if [[ -z $_cdt_file_gametype && -n $_cdt_split && -n $si_game_root_interface ]] && ! is_toc_multiple_types "$si_game_root_interface" ; then
									toc_to_type "$si_game_root_interface" "_cdt_file_gametype"
								fi
								if [[ -n "$_cdt_file_gametype" ]]; then
									_cdt_filters+="|toc_filter retail $([[ "$_cdt_file_gametype" != "retail" ]] && echo "true")"
									_cdt_filters+="|toc_filter version-retail $([[ "$_cdt_file_gametype" != "retail" ]] && echo "true")"
									_cdt_filters+="|toc_filter version-classic $([[ "$_cdt_file_gametype" != "classic" ]] && echo "true")"
									_cdt_filters+="|toc_filter version-vanilla $([[ "$_cdt_file_gametype" != "classic" ]] && echo "true")"
									_cdt_filters+="|toc_filter version-bcc $([[ "$_cdt_file_gametype" != "bcc" ]] && echo "true")"
									_cdt_filters+="|toc_filter version-wrath $([[ "$_cdt_file_gametype" != "wrath" ]] && echo "true")"
									_cdt_filters+="|toc_filter version-cata $([[ "$_cdt_file_gametype" != "cata" ]] && echo "true")"
									_cdt_filters+="|toc_filter version-mists $([[ "$_cdt_file_gametype" != "mists" ]] && echo "true")"
								fi
								# Rewrite the interface line if necessary
								_cdt_filters+="|toc_interface_filter '${si_game_type_interface_all[${_cdt_file_gametype:- }]}' '${toc_root_interface["$_cdt_source_file"]}'"
								# Do localized key replacements (this is really inefficient and should probably be deprecated)
								[ -n "$_cdt_localization" ] && grep -q "@localization" "$_cdt_source_file" && _cdt_filters+="|localization_filter"
							fi
							;;
					esac

					# Set the filter for normalizing line endings.
					_cdt_filters+="|line_ending_filter"

					# Set version control values for the file.
					set_info_file "$_cdt_source_file"

					echo "  Copying: $file${_cdt_external_slug:+ (embedded: "$_cdt_external_slug")}"

					# Make sure we're not causing any surprises
					if [[ -z $_cdt_file_gametype && ( $file == *".lua" || $file == *".xml" || ( -z $_cdt_external && $file == *".toc" ) ) ]] && grep -q '@\(non-\)\?version-\(retail\|classic\|vanilla\|bcc\|wrath\|cata\|mists\)@' "$_cdt_source_file"; then
						echo "    Error! Build type version keywords are not allowed in a multi-version build." >&2
						echo "           These should be replaced with lua conditional statements:" >&2
						grep -n '@\(non-\)\?version-\(retail\|classic\|vanilla\|bcc\|wrath\|cata\|mists\)@' "$_cdt_source_file" | sed 's/^/             /' >&2
						echo "           See https://wowpedia.fandom.com/wiki/WOW_PROJECT_ID" >&2
						exit 1
					fi

					set -o pipefail
					eval < "$_cdt_source_file" "$_cdt_filters" 3>&1 > "$_cdt_destdir/$file" || exit 1

					# Create game type specific TOCs
					if [[ -n $_cdt_split && -n ${toc_interfaces["$_cdt_source_file"]} ]]; then
						local toc_version new_file
						local root_toc_version="$si_game_root_interface"
						for type in "${!si_game_type_interface[@]}"; do
							toc_version="${si_game_type_interface[$type]}"
							new_file="${file%.toc}"
							case $type in
								retail) new_file+="_Mainline.toc" ;;
								classic) new_file+="_Vanilla.toc" ;;
								bcc) new_file+="_TBC.toc" ;;
								wrath) new_file+="_Wrath.toc" ;;
								cata) new_file+="_Cata.toc" ;;
								mists) new_file+="_Mists.toc" ;;
							esac

							echo "    Creating $new_file [${toc_version//:/, }]"

							_cdt_filters="vcs_filter"
							_cdt_filters+="|do_not_package_filter toc"
							[ -n "$_cdt_nolib" ] && _cdt_filters+="|toc_filter no-lib-strip true" # leave the tokens in the file normally
							_cdt_filters+="|toc_filter debug true"
							_cdt_filters+="|toc_filter alpha ${_cdt_alpha}"
							_cdt_filters+="|toc_filter retail $([[ "$type" != "retail" ]] && echo "true")"
							_cdt_filters+="|toc_filter version-retail $([[ "$type" != "retail" ]] && echo "true")"
							_cdt_filters+="|toc_filter version-classic $([[ "$type" != "classic" ]] && echo "true")"
							_cdt_filters+="|toc_filter version-vanilla $([[ "$type" != "classic" ]] && echo "true")"
							_cdt_filters+="|toc_filter version-bcc $([[ "$type" != "bcc" ]] && echo "true")"
							_cdt_filters+="|toc_filter version-wrath $([[ "$type" != "wrath" ]] && echo "true")"
							_cdt_filters+="|toc_filter version-cata $([[ "$type" != "cata" ]] && echo "true")"
							_cdt_filters+="|toc_filter version-mists $([[ "$type" != "mists" ]] && echo "true")"
							_cdt_filters+="|toc_interface_filter '$toc_version' '$root_toc_version'"
							_cdt_filters+="|line_ending_filter"

							eval < "$_cdt_source_file" "$_cdt_filters" 3>&1 > "$_cdt_destdir/$new_file"
						done

						if [[ -z $root_toc_version ]]; then
							echo "    Removing $file (no base interface)"
							rm -f "$_cdt_destdir/$file"
						fi
					fi
				fi
			fi
		fi
	done < <( cd "$_cdt_srcdir" && eval "$_cdt_find_cmd" )
	if [ -z "$_external_dir" ]; then
		end_group "copy"
	fi
}

if [ -z "$skip_copying" ]; then
	cdt_args="-dp"
	[ "$file_type" != "alpha" ] && cdt_args+="a"
	[ -z "$skip_localization" ] && cdt_args+="l"
	[ -n "$nolib" ] && cdt_args+="n"
	[ -n "$split" ] && cdt_args+="S"
	[ -n "$game_type" ] && cdt_args+=" -g $game_type"
	[ -n "$ignore" ] && cdt_args+=" -i \"$ignore\""
	[ -n "$unchanged" ] && cdt_args+=" -u \"$unchanged\""
	eval copy_directory_tree "$cdt_args" "\"$topdir\"" "\"$pkgdir\""
fi

# Reset ignore and parse pkgmeta ignores again to handle ignoring external paths
ignore=
unchanged=
parse_ignore "$pkgmeta_file"

###
### Process .pkgmeta again to perform any pre-move-folders actions.
###

# Checkout the external into a ".checkout" subdirectory of the final directory.
checkout_external() {
	local _external_dir="$1"
	local _external_uri="$2"
	local _external_tag="$3"
	local _external_type="$4"
	# shellcheck disable=SC2034
	local _external_slug="$5" # unused until we can easily fetch the project id
	local _external_checkout_type="$6"
	local _external_path="$7"

	_cqe_checkout_dir="$pkgdir/$_external_dir/.checkout"
	if [[ -d $_cqe_checkout_dir ]]; then
		# cleanup in case there was an aborted attempt to checkout
		rm -rf "$_cqe_checkout_dir"
	fi
	mkdir -p "$_cqe_checkout_dir"
	if [ "$_external_type" = "git" ]; then
		if [ -z "$_external_tag" ]; then
			echo "Fetching latest version of external $_external_uri"
			retry git clone -q --depth 1 "$_external_uri" "$_cqe_checkout_dir" || return 1
		elif [ "$_external_tag" != "latest" ]; then
			echo "Fetching $_external_checkout_type \"$_external_tag\" from external $_external_uri"
			if [ "$_external_checkout_type" = "commit" ]; then
				retry git clone -q "$_external_uri" "$_cqe_checkout_dir" || return 1
				git -C "$_cqe_checkout_dir" checkout -q "$_external_tag" || return 1
			else
				git -c advice.detachedHead=false clone -q --depth 1 --branch "$_external_tag" "$_external_uri" "$_cqe_checkout_dir" || return 1
			fi
		else # [ "$_external_tag" = "latest" ]; then
			retry git clone -q --depth 50 "$_external_uri" "$_cqe_checkout_dir" || return 1
			_external_tag=$( git -C "$_cqe_checkout_dir" for-each-ref refs/tags --sort=-creatordate --format=%\(refname:short\) --count=1 )
			if [ -n "$_external_tag" ]; then
				echo "Fetching tag \"$_external_tag\" from external $_external_uri"
				git -C "$_cqe_checkout_dir" checkout -q "$_external_tag" || return 1
			else
				echo "Fetching latest version of external $_external_uri"
			fi
		fi

		# pull submodules
		git -C "$_cqe_checkout_dir" submodule -q update --init --recursive || return 1

		set_info_git "$_cqe_checkout_dir"
		echo "Checked out $( git -C "$_cqe_checkout_dir" describe --always --tags --abbrev=7 --long )" #$si_project_abbreviated_hash
	elif [ "$_external_type" = "svn" ]; then
		if [[ $external_uri == *"/trunk" ]]; then
			_cqe_svn_trunk_url=$_external_uri
			_cqe_svn_subdir=
		else
			_cqe_svn_trunk_url="${_external_uri%/trunk/*}/trunk"
			_cqe_svn_subdir=${_external_uri#${_cqe_svn_trunk_url}/}
		fi

		if [ -z "$_external_tag" ]; then
			echo "Fetching latest version of external $_external_uri"
			retry_svn_checkout "$_external_uri" "$_cqe_checkout_dir" || return 1
		else
			_cqe_svn_tag_url="${_cqe_svn_trunk_url%/trunk}/tags"
			if [ "$_external_tag" = "latest" ]; then
				_external_tag=$( retry svn log --verbose --limit 1 "$_cqe_svn_tag_url" 2>/dev/null | awk '/^   A \/tags\// { print $2; exit }' | awk -F/ '{ print $3 }' )
				if [ -z "$_external_tag" ]; then
					_external_tag="latest"
				fi
			fi
			if [ "$_external_tag" = "latest" ]; then
				echo "No tags found in $_cqe_svn_tag_url"
				echo "Fetching latest version of external $_external_uri"
				retry_svn_checkout "$_external_uri" "$_cqe_checkout_dir" || return 1
			else
				_cqe_external_uri="${_cqe_svn_tag_url}/$_external_tag"
				if [ -n "$_cqe_svn_subdir" ]; then
					_cqe_external_uri="${_cqe_external_uri}/$_cqe_svn_subdir"
				fi
				echo "Fetching tag \"$_external_tag\" from external $_cqe_external_uri"
				retry_svn_checkout "$_cqe_external_uri" "$_cqe_checkout_dir" || return 1
			fi
		fi
		set_info_svn "$_cqe_checkout_dir" || return 1
		echo "Checked out r$si_project_revision"
	elif [ "$_external_type" = "hg" ]; then
		if [ -z "$_external_tag" ]; then
			echo "Fetching latest version of external $_external_uri"
			retry hg clone -q "$_external_uri" "$_cqe_checkout_dir" || return 1
		elif [ "$_external_tag" != "latest" ]; then
			echo "Fetching $_external_checkout_type \"$_external_tag\" from external $_external_uri"
			retry hg clone -q --updaterev "$_external_tag" "$_external_uri" "$_cqe_checkout_dir" || return 1
		else # [ "$_external_tag" = "latest" ]; then
			retry hg clone -q "$_external_uri" "$_cqe_checkout_dir" || return 1
			_external_tag=$( hg --cwd "$_cqe_checkout_dir" log -r . --template '{latesttag}' )
			if [ -n "$_external_tag" ]; then
				echo "Fetching tag \"$_external_tag\" from external $_external_uri"
				hg --cwd "$_cqe_checkout_dir" update -q "$_external_tag"
			else
				echo "Fetching latest version of external $_external_uri"
			fi
		fi
		set_info_hg "$_cqe_checkout_dir"
		echo "Checked out r$si_project_revision"
	else
		echo "Unknown external: $_external_uri" >&2
		return 1
	fi
	# Copy the checkout into the proper external directory.
	(
		cd "$_cqe_checkout_dir" || return 1
		# Set the slug for external localization, if needed.
		# Note: We don't actually do localization since we need the project id and
		# the only way to convert slug->id would be to scrape the project page :\
		slug= #$_external_slug
		project_site=
		package=
		if [[ "$_external_uri" == *"wowace.com"* || "$_external_uri" == *"curseforge.com"* ]]; then
			project_site="https://wow.curseforge.com"
		fi

		# If a .pkgmeta file is present, process it for "ignore" and "plain-copy" lists.
		parse_ignore "$_cqe_checkout_dir/.pkgmeta" "$_external_dir" "$_external_path"
		if [ -n "$_external_path" ]; then
			echo "Changing to /$_external_path"
			_cqe_checkout_dir="$_cqe_checkout_dir/$_external_path"
			cd "$_cqe_checkout_dir" || return 1
		fi
		copy_directory_tree -dnpe -i "$ignore" -u "$unchanged" "$_cqe_checkout_dir" "$pkgdir/$_external_dir"
	) || return 1
	# Remove the ".checkout" subdirectory containing the full checkout.
	if [ -d "$_cqe_checkout_dir" ]; then
		rm -fr "$_cqe_checkout_dir"
	fi
}

external_pids=()

external_dir=
external_uri=
external_tag=
external_type=
external_slug=
external_checkout_type=
external_path=
process_external() {
	if [ -n "$external_dir" ] && [ -n "$external_uri" ] && [ -z "$skip_externals" ]; then
		echo "Fetching external: $external_dir"

		external_uri=${external_uri%%#*} # strip trailing comment
		external_uri=${external_uri% *}  # strip trailing space
		external_uri=${external_uri%/}   # strip trailing slash

		# convert old curse repo urls
		case $external_uri in
			*git.curseforge.com*|*git.wowace.com*)
				external_type="git"
				# git://git.curseforge.com/wow/$slug/mainline.git -> https://repos.curseforge.com/wow/$slug
				external_uri=${external_uri%/mainline.git}
				external_uri="https://repos${external_uri#*://git}"
				;;
			*svn.curseforge.com*|*svn.wowace.com*)
				external_type="svn"
				# svn://svn.curseforge.com/wow/$slug/mainline/trunk -> https://repos.curseforge.com/wow/$slug/trunk
				external_uri=${external_uri/\/mainline/}
				external_uri="https://repos${external_uri#*://svn}"
				;;
			*hg.curseforge.com*|*hg.wowace.com*)
				external_type="hg"
				# http://hg.curseforge.com/wow/$slug/mainline -> https://repos.curseforge.com/wow/$slug
				external_uri=${external_uri%/mainline}
				external_uri="https://repos${external_uri#*://hg}"
				;;
			svn:*)
				# just in case
				external_type="svn"
				;;
			*)
				if [ -z "$external_type" ]; then
					external_type="git"
				fi
				;;
		esac

		if [[ $external_uri == "https://repos.curseforge.com/wow/"* || $external_uri == "https://repos.wowace.com/wow/"* ]]; then
			if [ -z "$external_slug" ]; then
				external_slug=${external_uri#*/wow/}
				external_slug=${external_slug%%/*}
			fi

			# check if the repo is svn
			local _svn_path=${external_uri#*/wow/$external_slug/}
			if [[ "$_svn_path" == "trunk"* ]]; then
				external_type="svn"
			elif [[ "$_svn_path" == "tags/"* ]]; then
				external_type="svn"
				# change the tag path into the trunk path and use the tag var so it gets logged as a tag
				external_tag=${_svn_path#tags/}
				external_tag=${external_tag%%/*}
				external_uri="${external_uri%/tags*}/trunk${_svn_path#tags/$external_tag}"
			fi
		fi

		if [[ $external_type == "git" ]]; then
			if ! command -v git &>/dev/null; then
				echo "    ERROR! \"$external_uri\" is a git repository, but git is not available." >&2
				exit 1
			fi
			# check for subpath in urls we know the structure of
			if [[ -n $external_slug && $external_uri == *"$external_slug/"* ]]; then
				# CF: https://repos.curseforge.com/wow/libdothings-1-0/LibDoThings-1.0
				external_path=${external_uri#*/wow/$external_slug/}
				external_uri=${external_uri%/$external_path*}
			elif [[ $external_uri == "https://github.com/"*/*/* ]]; then
				# GitHub: https://github.com/nebularg/LibDoThings-1.0.git/LibDoThings-1.0
				external_path=${external_uri#*.com/*/*/}
				external_uri=${external_uri%/$external_path*}
			fi
		elif [[ $external_type == "svn" ]]; then
			if ! command -v svn &>/dev/null; then
				echo "    ERROR! \"$external_uri\" is a subversion repository, but svn is not available." >&2
				exit 1
			fi
		elif [[ $external_type == "hg" ]]; then
			if ! command -v hg &>/dev/null; then
				echo "    ERROR! \"$external_uri\" is a mercurial repository, but hg is not available." >&2
				exit 1
			fi
		fi

		if [ -n "$external_slug" ]; then
			relations["${external_slug,,}"]="embeddedLibrary"
		fi

		checkout_external "$external_dir" "$external_uri" "$external_tag" "$external_type" "$external_slug" "$external_checkout_type" "$external_path" &> "$releasedir/.$BASHPID.externalout" &
		external_pids+=($!)
	fi
	external_dir=
	external_uri=
	external_tag=
	external_type=
	external_slug=
	external_checkout_type=
	external_path=
}

# Don't leave extra files around if exited early
kill_externals() {
	rm -f "$releasedir"/.*.externalout
	kill 0
}
trap kill_externals INT

if [ -z "$skip_externals" ] && [ -f "$pkgmeta_file" ]; then
	yaml_eof=
	while [ -z "$yaml_eof" ]; do
		IFS='' read -r yaml_line || yaml_eof="true"
		# Skip commented out lines.
		if [[ $yaml_line =~ ^[[:space:]]*\# ]]; then
			continue
		fi
		# Strip any trailing CR character.
		yaml_line="${yaml_line%"$carriage_return"}"

		case $yaml_line in
			[!\ ]*:*)
				# Started a new section, so checkout any queued externals.
				process_external
				# Split $yaml_line into a $yaml_key, $yaml_value pair.
				yaml_keyvalue "$yaml_line"
				# Set the $pkgmeta_phase for stateful processing.
				pkgmeta_phase="$yaml_key"
				;;
			" "*)
				yaml_line="${yaml_line#"${yaml_line%%[! ]*}"}" # trim leading whitespace
				case $yaml_line in
					"- "*)
						;;
					*:*)
						# Split $yaml_line into a $yaml_key, $yaml_value pair.
						yaml_keyvalue "$yaml_line"
						case $pkgmeta_phase in
							externals)
								case $yaml_key in
									url) external_uri="$yaml_value" ;;
									tag)
										external_tag="$yaml_value"
										external_checkout_type="$yaml_key"
										;;
									branch)
										external_tag="$yaml_value"
										external_checkout_type="$yaml_key"
										;;
									commit)
										external_tag="$yaml_value"
										external_checkout_type="$yaml_key"
										;;
									type) external_type="$yaml_value" ;;
									curse-slug) external_slug="$yaml_value" ;;
									path) external_path="$yaml_value" ;;
									*)
										# Started a new external, so checkout any queued externals.
										process_external

										external_dir="$yaml_key"
										nolib_exclude="$nolib_exclude $pkgdir/$external_dir/*"
										if [ -n "$yaml_value" ]; then
											external_uri="$yaml_value"
											# Immediately checkout this fully-specified external.
											process_external
										fi
										;;
								esac
								;;
						esac
						;;
				esac
				;;
		esac
	done < "$pkgmeta_file"
	# Reached end of file, so checkout any remaining queued externals.
	process_external

	if [ ${#external_pids[*]} -gt 0 ]; then
		echo
		echo "Waiting for externals to finish..."
		echo

		while [ ${#external_pids[*]} -gt 0 ]; do
			wait -n
			for i in ${!external_pids[*]}; do
				pid=${external_pids[i]}
				if ! kill -0 "$pid" 2>/dev/null; then
					_external_output="$releasedir/.$pid.externalout"
					if ! wait "$pid"; then
						_external_error=1
						# wrap each line with a bright red color code
						awk '{ printf "\033[01;31m%s\033[0m\n", $0 }' "$_external_output"
						echo
					else
						start_group "$( head -n1 "$_external_output" )" "external.$pid"
						tail -n+2 "$_external_output"
						end_group "external.$pid"
					fi
					rm -f "$_external_output" 2>/dev/null
					unset 'external_pids[i]'
				fi
			done
		done

		if [ -n "$_external_error" ]; then
			echo
			echo "There was an error fetching externals :(" >&2
			exit 1
		fi
	fi
fi

# Restore the signal handlers
trap - INT

###
### Create the changelog of commits since the previous release tag.
###

if [ -z "$project" ]; then
	project="$package"
fi

# Create a changelog in the package directory if the source directory does
# not contain a manual changelog.

changelog_path=
if [[ -n "$manual_changelog" && -f "$topdir/$changelog" ]]; then
	if [[ -f "$pkgdir/$changelog" ]]; then
		# use the processed copy
		changelog_path="$pkgdir/$changelog"
	else
		changelog_path="$topdir/$changelog"
	fi
	start_group "Using manual changelog $changelog" "changelog"
	head -n7 "$changelog_path"
	[ "$( wc -l < "$changelog_path" )" -gt 7 ] && echo "..."
	end_group "changelog"

	# Convert Markdown to BBCode (with HTML as an intermediary) for sending to WoWInterface
	# Requires pandoc (http://pandoc.org/)
	if [ "$changelog_markup" = "markdown" ] && [ -n "$wowi_convert_changelog" ] && command -v pandoc &>/dev/null; then
		wowi_changelog="$releasedir/WOWI-$project_version-CHANGELOG.txt"
		pandoc -f commonmark -t html "$changelog_path" | sed \
			-e 's/<\(\/\)\?\(b\|i\|u\)>/[\1\2]/g' \
			-e 's/<\(\/\)\?em>/[\1i]/g' \
			-e 's/<\(\/\)\?strong>/[\1b]/g' \
			-e 's/<ul[^>]*>/[list]/g' -e 's/<ol[^>]*>/[list="1"]/g' \
			-e 's/<\/[ou]l>/[\/list]\n/g' \
			-e 's/<li><p>/[*]/g' -e 's/<li>/[*]/g' -e 's/<\/p><\/li>//g' -e 's/<\/li>//g' \
			-e 's/\[\*\]\[ \] /[*]☐ /g' -e 's/\[\*\]\[[xX]\] /[*]☒ /g' \
			-e 's/<h1[^>]*>/[size="6"]/g' -e 's/<h2[^>]*>/[size="5"]/g' -e 's/<h3[^>]*>/[size="4"]/g' \
			-e 's/<h4[^>]*>/[size="3"]/g' -e 's/<h5[^>]*>/[size="3"]/g' -e 's/<h6[^>]*>/[size="3"]/g' \
			-e 's/<\/h[1-6]>/[\/size]\n/g' \
			-e 's/<blockquote>/[quote]/g' -e 's/<\/blockquote>/[\/quote]\n/g' \
			-e 's/<div class="sourceCode"[^>]*><pre class="sourceCode lua"><code class="sourceCode lua">/[highlight="lua"]/g' -e 's/<\/code><\/pre><\/div>/[\/highlight]\n/g' \
			-e 's/<pre><code>/[code]/g' -e 's/<\/code><\/pre>/[\/code]\n/g' \
			-e 's/<code>/[font="monospace"]/g' -e 's/<\/code>/[\/font]/g' \
			-e 's/<a href=\"\([^"]\+\)\"[^>]*>/[url="\1"]/g' -e 's/<\/a>/\[\/url]/g' \
			-e 's/<img src=\"\([^"]\+\)\"[^>]*>/[img]\1[\/img]/g' \
			-e 's/<hr \/>/_____________________________________________________________________________\n/g' \
			-e 's/<\/p>/\n/g' \
			-e '/^<[^>]\+>$/d' -e 's/<[^>]\+>//g' \
			-e 's/&quot;/"/g' \
			-e 's/&amp;/&/g' \
			-e 's/&lt;/</g' \
			-e 's/&gt;/>/g' \
			-e "s/&#39;/'/g" \
			| line_ending_filter > "$wowi_changelog"
	fi
else
	if [ -n "$manual_changelog" ]; then
		echo "Warning! Could not find a manual changelog at $topdir/$changelog"
		manual_changelog=
	fi
	changelog="CHANGELOG.md"
	changelog_markup="markdown"
	changelog_path="$pkgdir/$changelog"

	if [ -n "$wowi_gen_changelog" ] && [ -z "$wowi_convert_changelog" ]; then
		wowi_markup="markdown"
	fi

	start_group "Generating changelog of commits into $changelog" "changelog"

	_changelog_range=
	if [ "$repository_type" = "git" ]; then
		changelog_url=
		changelog_version=
		changelog_previous="[Previous Releases](${project_github_url}/releases)"
		changelog_url_wowi=
		changelog_version_wowi=
		changelog_previous_wowi="[url=${project_github_url}/releases]Previous Releases[/url]"
		if [ -z "$previous_version" ] && [ -z "$tag" ]; then
			# no range, show all commits up to ours
			changelog_url="[Full Changelog](${project_github_url}/commits/${project_hash})"
			changelog_version="[${project_version}](${project_github_url}/tree/${project_hash})"
			changelog_url_wowi="[url=${project_github_url}/commits/${project_hash}]Full Changelog[/url]"
			changelog_version_wowi="[url=${project_github_url}/tree/${project_hash}]${project_version}[/url]"
			_changelog_range="$project_hash"
		elif [ -z "$previous_version" ] && [ -n "$tag" ]; then
			# first tag, show all commits upto it
			changelog_url="[Full Changelog](${project_github_url}/commits/${tag})"
			changelog_version="[${project_version}](${project_github_url}/tree/${tag})"
			changelog_url_wowi="[url=${project_github_url}/commits/${tag}]Full Changelog[/url]"
			changelog_version_wowi="[url=${project_github_url}/tree/${tag}]${project_version}[/url]"
			_changelog_range="$tag"
		elif [ -n "$previous_version" ] && [ -z "$tag" ]; then
			# compare between last tag and our commit
			changelog_url="[Full Changelog](${project_github_url}/compare/${previous_version}...${project_hash})"
			changelog_version="[$project_version](${project_github_url}/tree/${project_hash})"
			changelog_url_wowi="[url=${project_github_url}/compare/${previous_version}...${project_hash}]Full Changelog[/url]"
			changelog_version_wowi="[url=${project_github_url}/tree/${project_hash}]${project_version}[/url]"
			_changelog_range="$previous_version..$project_hash"
		elif [ -n "$previous_version" ] && [ -n "$tag" ]; then
			# compare between last tag and our tag
			changelog_url="[Full Changelog](${project_github_url}/compare/${previous_version}...${tag})"
			changelog_version="[$project_version](${project_github_url}/tree/${tag})"
			changelog_url_wowi="[url=${project_github_url}/compare/${previous_version}...${tag}]Full Changelog[/url]"
			changelog_version_wowi="[url=${project_github_url}/tree/${tag}]${project_version}[/url]"
			_changelog_range="$previous_version..$tag"
		fi
		# lazy way out
		if [ -z "$project_github_url" ]; then
			changelog_url=
			changelog_version=$project_version
			changelog_previous=
			changelog_url_wowi=
			changelog_version_wowi="[color=orange]${project_version}[/color]"
			changelog_previous_wowi=
		elif [ -z "$github_token" ]; then
			# not creating releases :(
			changelog_previous=
			changelog_previous_wowi=
		fi
		changelog_date=$( TZ='' printf "%(%Y-%m-%d)T" "$project_timestamp" )

		cat <<- EOF | line_ending_filter > "$changelog_path"
		# $project

		## $changelog_version ($changelog_date)
		$changelog_url $changelog_previous

		EOF
		# ignore sed matching backticks
		# shellcheck disable=SC2016
		git -C "$topdir" log "$_changelog_range" --pretty=format:"###%B" \
			| sed -e 's/^/    /g' -e 's/^ *$//g' -e 's/^    ###/- /g' -e 's/$/  /' \
			      -e ':a;s/^\(\(`[^`]*`\|[^`_]*\)*\)_/\1\\###/;ta' -e 's/###/_/g' \
			      -e 's/\[ci skip\]//g' -e 's/\[skip ci\]//g' \
			      -e '/git-svn-id:/d' -e '/^[[:space:]]*This reverts commit [0-9a-f]\{40\}\.[[:space:]]*$/d' \
			      -e '/^[[:space:]]*$/d' \
			| line_ending_filter >> "$changelog_path"

		# WoWI uses BBCode, generate something usable to post to the site
		# the file is deleted on successful upload
		if [ -n "$addonid" ] && [ -n "$tag" ] && [ -n "$wowi_gen_changelog" ] && [ "$wowi_markup" = "bbcode" ]; then
			wowi_changelog="$releasedir/WOWI-$project_version-CHANGELOG.txt"
			cat <<- EOF | line_ending_filter > "$wowi_changelog"
			[size=5]${project}[/size]
			[size=4]${changelog_version_wowi} (${changelog_date})[/size]
			${changelog_url_wowi} ${changelog_previous_wowi}
			[list]
			EOF
			git -C "$topdir" log "$_changelog_range" --pretty=format:"###%B" \
				| sed -e 's/^/    /g' -e 's/^ *$//g' -e 's/^    ###/[*]/g' \
				      -e 's/\[ci skip\]//g' -e 's/\[skip ci\]//g' \
				      -e '/git-svn-id:/d' -e '/^[[:space:]]*This reverts commit [0-9a-f]\{40\}\.[[:space:]]*$/d' \
				      -e '/^[[:space:]]*$/d' \
				| line_ending_filter >> "$wowi_changelog"
			echo "[/list]" | line_ending_filter >> "$wowi_changelog"
		fi

	elif [ "$repository_type" = "svn" ]; then
		if [ -n "$previous_revision" ]; then
			_changelog_range="-r$project_revision:$previous_revision"
		else
			_changelog_range="-rHEAD:1"
		fi
		changelog_date=$( TZ='' printf "%(%Y-%m-%d)T" "$project_timestamp" )

		cat <<- EOF | line_ending_filter > "$changelog_path"
		# $project

		## $project_version ($changelog_date)

		EOF
		_svn_changelog=$( retry svn log "$topdir" "$_changelog_range" --xml )
		# ignore sed matching backticks
		# shellcheck disable=SC2016
		echo "$_svn_changelog" \
			| awk '/<msg>/,/<\/msg>/' \
			| sed -e 's/<msg>/###/g' -e 's/<\/msg>//g' \
			      -e 's/^/    /g' -e 's/^ *$//g' -e 's/^    ###/- /g' -e 's/$/  /' \
			      -e ':a;s/^\(\(`[^`]*`\|[^`_]*\)*\)_/\1\\###/;ta' -e 's/###/_/g' \
			      -e 's/\[ci skip\]//g' -e 's/\[skip ci\]//g' \
			      -e '/^[[:space:]]*$/d' \
			| line_ending_filter >> "$changelog_path"

		# WoWI uses BBCode, generate something usable to post to the site
		# the file is deleted on successful upload
		if [ -n "$addonid" ] && [ -n "$tag" ] && [ -n "$wowi_gen_changelog" ] && [ "$wowi_markup" = "bbcode" ]; then
			wowi_changelog="$releasedir/WOWI-$project_version-CHANGELOG.txt"
			cat <<- EOF | line_ending_filter > "$wowi_changelog"
			[size=5]${project}[/size]
			[size=4][color=orange]${project_version}[/color] (${changelog_date})[/size]

			[list]
			EOF
			echo "$_svn_changelog" \
				| awk '/<msg>/,/<\/msg>/' \
				| sed -e 's/<msg>/###/g' -e 's/<\/msg>//g' \
				      -e 's/^/    /g' -e 's/^ *$//g' -e 's/^    ###/[*]/g' \
				      -e 's/\[ci skip\]//g' -e 's/\[skip ci\]//g' \
				      -e '/^[[:space:]]*$/d' \
				| line_ending_filter >> "$wowi_changelog"
			echo "[/list]" | line_ending_filter >> "$wowi_changelog"
		fi
		unset _svn_changelog

	elif [ "$repository_type" = "hg" ]; then
		if [ -n "$previous_revision" ]; then
			_changelog_range="::$project_revision - ::$previous_revision - filelog(.hgtags)"
		else
			_changelog_range="."
		fi
		changelog_date=$( TZ='' printf "%(%Y-%m-%d)T" "$project_timestamp" )

		cat <<- EOF | line_ending_filter > "$changelog_path"
		# $project

		## $project_version ($changelog_date)

		EOF
		hg --cwd "$topdir" log -r "$_changelog_range" --template '- {fill(desc|strip, 76, "", "  ")}\n' | line_ending_filter >> "$changelog_path"

		# WoWI uses BBCode, generate something usable to post to the site
		# the file is deleted on successful upload
		if [ -n "$addonid" ] && [ -n "$tag" ] && [ -n "$wowi_gen_changelog" ] && [ "$wowi_markup" = "bbcode" ]; then
			wowi_changelog="$releasedir/WOWI-$project_version-CHANGELOG.txt"
			cat <<- EOF | line_ending_filter > "$wowi_changelog"
			[size=5]${project}[/size]
			[size=4][color=orange]${project_version}[/color] (${changelog_date})[/size]

			[list]
			EOF
			hg --cwd "$topdir" log "$_changelog_range" --template '[*]{desc|strip|escape}\n' | line_ending_filter >> "$wowi_changelog"
			echo "[/list]" | line_ending_filter >> "$wowi_changelog"
		fi
	fi

	echo "$(<"$changelog_path")"
	end_group "changelog"
fi

###
### Create a license if not present and .pkgmeta requests one.
###

if [[ -n "$license" && ! -f "$topdir/$license" && -n "$slug" ]]; then
	start_group "Saving license as $license" "license"
	# this only exists on wowace.com now
	if license_text=$( curl -sf --retry 3 --retry-delay 10 "https://www.wowace.com/project/$slug/license" 2>/dev/null ); then
		# text is wrapped with \n\n<div class="module">\n\t<p>\n\t\t ... \n\t</p>\n</div>\n
		echo "$license_text" | sed -e '1,4d' -e '5s/^\s*//' -e '$d' | sed '$d' > "$pkgdir/$license"
		head -n10 "$pkgdir/$license"
		[[ "$( wc -l < "$pkgdir/$license" )" -gt 10 ]] && echo "..."
	else
		echo "There was an error saving the license. ($?)"
	fi
	end_group "license"
fi

###
### Process .pkgmeta to perform move-folders actions.
###

if [ -f "$pkgmeta_file" ]; then
	yaml_eof=
	while [ -z "$yaml_eof" ]; do
		IFS='' read -r yaml_line || yaml_eof="true"
		# Skip commented out lines.
		if [[ $yaml_line =~ ^[[:space:]]*\# ]]; then
			continue
		fi
		# Strip any trailing CR character.
		yaml_line=${yaml_line%$carriage_return}

		case $yaml_line in
			[!\ ]*:*)
				# Split $yaml_line into a $yaml_key, $yaml_value pair.
				yaml_keyvalue "$yaml_line"
				# Set the $pkgmeta_phase for stateful processing.
				pkgmeta_phase=$yaml_key
				;;
			" "*)
				yaml_line=${yaml_line#"${yaml_line%%[! ]*}"} # trim leading whitespace
				case $yaml_line in
					"- "*)
						;;
					*:*)
						# Split $yaml_line into a $yaml_key, $yaml_value pair.
						yaml_keyvalue "$yaml_line"
						case $pkgmeta_phase in
							move-folders)
								srcdir="$releasedir/$yaml_key"
								destdir="$releasedir/$yaml_value"
								if [[ -d "$destdir" && -z "$overwrite" && "$srcdir" != "$destdir/"* ]]; then
									rm -fr "$destdir"
								fi
								if [ -d "$srcdir" ]; then
									if [ ! -d "$destdir" ]; then
										mkdir -p "$destdir"
									fi
									echo "Moving $yaml_key to $yaml_value"
									mv -f "$srcdir"/* "$destdir" && rm -fr "$srcdir"
									zip_root_dirs+=("$yaml_value")
									# Copy the license into $destdir if one doesn't already exist.
									if [[ -n "$license" && -f "$pkgdir/$license" && ! -f "$destdir/$license" ]]; then
										cp -f "$pkgdir/$license" "$destdir/$license"
									fi
									# Check to see if the base source directory is empty
									_mf_basedir="/${yaml_key%/*}"
									while [[ -n "$_mf_basedir" && -z "$( ls -A "${releasedir}${_mf_basedir}" )" ]]; do
										echo "Removing empty directory ${_mf_basedir#/}"
										rm -fr "${releasedir}${_mf_basedir}"
										_mf_basedir="${_mf_basedir%/*}"
									done
								fi
								# update external dir
								nolib_exclude=${nolib_exclude//$srcdir/$destdir}
								;;
						esac
						;;
				esac
				;;
		esac
	done < "$pkgmeta_file"
	if [ -n "$srcdir" ]; then
		echo
	fi
fi

###
### Create the final zipfile for the addon.
###

if [ -z "$skip_zipfile" ]; then
	archive_version="$project_version" # XXX used for wowi version. should probably switch to label, but the game type gets added on by default :\
	archive_label="$( filename_filter "$label_template" )"
	archive_name="$( filename_filter "$file_template" ).zip"
	archive="$releasedir/$archive_name"

	nolib_archive_version="${project_version}-nolib"
	nolib_archive_label="$( nolib=true filename_filter "$archive_label" )"
	nolib_archive_name="$( nolib=true filename_filter "$file_template" ).zip"
	# someone didn't include {nolib} and they're forcing nolib creation
	if [ "$archive_label" = "$nolib_archive_label" ]; then
		nolib_archive_label="${nolib_archive_label}-nolib"
	fi
	if [ "$archive_name" = "$nolib_archive_name" ]; then
		nolib_archive_name="${nolib_archive_name%.zip}-nolib.zip"
	fi
	nolib_archive="$releasedir/$nolib_archive_name"

	if [ -n "$nolib" ]; then
		archive_version="$nolib_archive_version"
		archive_label="$nolib_archive_label"
		archive_name="$nolib_archive_name"
		archive="$nolib_archive"
		nolib_archive=
	fi

	if [[ -n $GITHUB_ACTIONS ]]; then
		echo "archive_path=${archive}" >> "$GITHUB_OUTPUT"
	fi

	start_group "Creating archive: $archive_name ($archive_label)" "archive"
	if [ -f "$archive" ]; then
		rm -f "$archive"
	fi
	( cd "$releasedir" && zip -X -r "$archive" "${zip_root_dirs[@]}" )

	if [ ! -f "$archive" ]; then
		exit 1
	fi
	end_group "archive"

	# Create nolib version of the zipfile
	if [ -n "$enable_nolib_creation" ] && [ -z "$nolib" ] && [ -n "$nolib_exclude" ]; then
		# run the nolib_filter
		find "$pkgdir" -type f \( -name "*.xml" -o -name "*.toc" \) -print | while read -r file; do
			case $file in
				*.toc) _filter="toc_filter no-lib-strip true" ;;
				*.xml) _filter="xml_filter no-lib-strip" ;;
			esac
			$_filter < "$file" > "$file.tmp" && mv "$file.tmp" "$file"
		done

		# make the exclude paths relative to the release directory
		nolib_exclude=${nolib_exclude//$releasedir\//}

		start_group "Creating no-lib archive: $nolib_archive_name ($nolib_archive_label)" "archive.nolib"
		if [ -f "$nolib_archive" ]; then
			rm -f "$nolib_archive"
		fi
		# set noglob so each nolib_exclude path gets quoted instead of expanded
		# shellcheck disable=SC2086
		( set -f; cd "$releasedir" && zip -X -r -q "$nolib_archive" "${zip_root_dirs[@]}" -x $nolib_exclude )

		if [ ! -f "$nolib_archive" ]; then
			exit_code=1
		fi
		end_group "archive.nolib"
	fi
fi

###
### Deploy the zipfile.
###

# Upload to CurseForge.
upload_curseforge() {
	if [[ -n "$skip_cf_upload" || -z "$slug" || -z "$cf_token" || -z "$project_site" ]]; then
		return 0
	fi

	local _cf_game_version_id _cf_game_version _cf_versions
	_cf_versions=$( curl -s -H "x-api-token: $cf_token" "$project_site/api/game/wow/versions" )
	if [[ -n $_cf_versions && $_cf_versions != *"errorMessage"* ]]; then
		_cf_game_version_id=
		_cf_game_version=
		local version_id game_id invalid_version
		for type in "${!game_type_version[@]}"; do
			case $type in
				classic) game_id=67408 ;;
				bcc) game_id=73246 ;;
				wrath) game_id=73713 ;;
				cata) game_id=77522 ;;
				mists) game_id=79434 ;;
				*) game_id=517
			esac
			IFS=':' read -ra V <<< "${game_type_version[$type]}"
			for version in "${V[@]}"; do
				# check the version
				if ! jq -e --arg v "$version" --argjson t "$game_id" 'map(select(.gameVersionTypeID == $t and .name == $v)) | length > 0' <<< "$_cf_versions" &>/dev/null; then
					invalid_version="$version"
					# no match, so grab the next highest version (try to avoid testing versions)
					version=$( echo "$_cf_versions" | jq -r --arg v "$invalid_version" --argjson t "$game_id" 'map(select(.gameVersionTypeID == $t and .name < $v)) | max_by(.id) | .name // empty' )
					if [[ -z $version ]]; then
						# no? just grab the highest version
						version=$( echo "$_cf_versions" | jq -r --argjson t "$game_id" 'map(select(.gameVersionTypeID == $t)) | max_by(.id) | .name // empty' )
					fi
					if [[ -z $version ]]; then
						echo "WARNING: No CurseForge game version match for \"$invalid_version\", ignoring" >&2
					else
						echo "WARNING: No CurseForge game version match for \"$invalid_version\", using \"$version\"" >&2
					fi
				fi
				if [[ -n $version && "$_cf_game_version," != *",$version," ]]; then
					_cf_game_version+=",${version}"
					# get the id
					version_id=$( echo "$_cf_versions" | jq -r --arg v "$version" --argjson t "$game_id" '.[] | select(.gameVersionTypeID == $t and .name == $v) | .id // empty' )
					_cf_game_version_id+=",${version_id}"
				fi
			done
		done
		_cf_game_version_id="[${_cf_game_version_id#,}]"
		_cf_game_version=$( echo "${_cf_game_version#,}" | tr ',' '\n' | sort -Vr | tr '\n' ',' )
		_cf_game_version=${_cf_game_version%,}
	fi
	if [ -z "$_cf_game_version" ]; then
		echo "Error fetching game version info from $project_site/api/game/versions"
		echo
		echo "Skipping upload to CurseForge."
		echo
		exit_code=1
		return 0
	fi

	local _cf_payload _cf_payload_relations
	local resultfile result
	local return_code=0

	_cf_payload=$( cat <<-EOF
	{
	  "displayName": "$archive_label",
	  "gameVersions": $_cf_game_version_id,
	  "releaseType": "$file_type",
	  "changelog": $( jq --slurp --raw-input '.' < "$changelog_path" ),
	  "changelogType": "$changelog_markup"
	}
	EOF
	)
	_cf_payload_relations=
	for i in "${!relations[@]}"; do
		_cf_payload_relations="$_cf_payload_relations{\"slug\":\"$i\",\"type\":\"${relations[$i]}\"},"
	done
	if [[ -n $_cf_payload_relations ]]; then
		_cf_payload_relations="{\"relations\":{\"projects\":[${_cf_payload_relations%,}]}}"
		_cf_payload=$( echo "$_cf_payload $_cf_payload_relations" | jq -s -c '.[0] * .[1]' )
	fi

	echo "Uploading $archive_name ($_cf_game_version $file_type) to https://wow.curseforge.com/projects/$slug"
	resultfile="$releasedir/cf_result.json"
	if result=$( echo "$_cf_payload" | curl -sS --retry 3 --retry-delay 10 \
			-w "%{http_code}" -o "$resultfile" \
			-H "x-api-token: $cf_token" \
			-F "metadata=<-" \
			-F "file=@$archive" \
			"$project_site/api/projects/$slug/upload-file"
	); then
		case $result in
			200) echo "Success!" ;;
			302)
				echo "Error! ($result)"
				# don't need to ouput the redirect page
				return_code=1
				;;
			404)
				echo "Error! No project for \"$slug\" found."
				return_code=1
				;;
			*)
				echo "Error! ($result)"
				if [ -s "$resultfile" ]; then
					echo "$(<"$resultfile")"
				fi
				return_code=1
				;;
		esac
	else
		return_code=1
	fi
	echo

	rm -f "$resultfile" 2>/dev/null

	# shellcheck disable=SC2086
	return $return_code
}

# Upload tags to WoWInterface.
upload_wowinterface() {
	if [[ -z "$tag" || -z "$addonid" || -z "$wowi_token" ]]; then
		return 0
	fi

	local _wowi_versions _wowi_game_version
	_wowi_versions=$( curl -s https://api.wowinterface.com/addons/compatible.json )
	if [ -n "$_wowi_versions" ]; then
		local wowi_type invalid_version
		for type in "${!game_type_version[@]}"; do
			case $type in
				classic) wowi_type="Classic" ;;
				bcc) wowi_type="TBC-Classic" ;;
				wrath) wowi_type="WOTLK-Classic" ;;
				cata) wowi_type="Cata-Classic" ;;
				mists) wowi_type="MOP-Classic" ;; # XXX nyi
				*) wowi_type="Retail"
			esac
			IFS=':' read -ra V <<< "${game_type_version[$type]}"
			for version in "${V[@]}"; do
				# check the version
				if ! jq -e --arg v "$version" 'map(select(.id == $v)) | length > 0' <<< "$_wowi_versions" &>/dev/null; then
					invalid_version="$version"
					# use the next highest version (try to avoid testing versions)
					version=$( echo "$_wowi_versions" | jq -r --arg v "$invalid_version" --arg t "$wowi_type" 'map(select(.game == $t and .id < $v)) | max_by(.id) | .id // empty' )
					if [[ -z $version ]]; then
						if [[ $wowi_type == "MOP-Classic" ]]; then # XXX compat: not supported yet or I guessed the wrong name
							wowi_type="Cata-Classic"
						fi
						# just grab the highest version
						version=$( echo "$_wowi_versions" | jq -r --arg t "$wowi_type" 'map(select(.game == $t)) | max_by(.id) | .id // empty' )
					fi
					if [[ -z $version ]]; then
						echo "WARNING: No WoWInterface game version match for \"$invalid_version\", \"$wowi_type\" is not supported" >&2
					else
						echo "WARNING: No WoWInterface game version match for \"$invalid_version\", using \"$version\"" >&2
					fi
				fi
				if [[ -n $version && "$_wowi_game_version," != *",$version," ]]; then
					_wowi_game_version+=",${version}"
				fi
			done
		done
		_wowi_game_version=$( echo "${_wowi_game_version#,}" | tr ',' '\n' | sort -Vr | tr '\n' ',' )
		_wowi_game_version=${_wowi_game_version%,}
	fi
	if [ -z "$_wowi_game_version" ]; then
		echo "Error fetching game version info from https://api.wowinterface.com/addons/compatible.json"
		echo
		echo "Skipping upload to WoWInterface."
		echo
		exit_code=1
		return 1
	fi

	local -a _wowi_args
	local resultfile result
	local return_code=0

	if [ -f "$wowi_changelog" ]; then
		_wowi_args+=("-F changelog=<$wowi_changelog")
	elif [ -n "$manual_changelog" ] || [ "$wowi_markup" = "markdown" ]; then
		_wowi_args+=("-F changelog=<$changelog_path")
	fi
	if [ -z "$wowi_archive" ]; then
		_wowi_args+=("-F archive=No")
	fi

	echo "Uploading $archive_name ($_wowi_game_version) to https://www.wowinterface.com/downloads/info$addonid"
	resultfile="$releasedir/wi_result.json"
	if result=$( curl -sS --retry 3 --retry-delay 10 \
			-w "%{http_code}" -o "$resultfile" \
			-H "x-api-token: $wowi_token" \
			-F "id=$addonid" \
			-F "version=$archive_version" \
			-F "compatible=$_wowi_game_version" \
			"${_wowi_args[@]}" \
			-F "updatefile=@$archive" \
			"https://api.wowinterface.com/addons/update"
	); then
		case $result in
			202)
				echo "Success!"
				if [ -f "$wowi_changelog" ]; then
					rm -f "$wowi_changelog" 2>/dev/null
				fi
				;;
			401)
				echo "Error! No addon for id \"$addonid\" found or you do not have permission to upload files."
				return_code=1
				;;
			403)
				echo "Error! Incorrect api key or you do not have permission to upload files."
				return_code=1
				;;
			*)
				echo "Error! ($result)"
				if [ -s "$resultfile" ]; then
					echo "$(<"$resultfile")"
				fi
				return_code=1
				;;
		esac
	else
		return_code=1
	fi
	echo

	rm -f "$resultfile" 2>/dev/null

	# shellcheck disable=SC2086
	return $return_code
}

# Upload to Wago
upload_wago() {
	if [[ -z "$wagoid" || -z "$wago_token" ]]; then
		return 0
	fi

	local _wago_versions _wago_game_version _wago_support_property
	_wago_versions=$( curl -s https://addons.wago.io/api/data/game | jq -c '.patches' 2>/dev/null )
	if [ -n "$_wago_versions" ]; then
		_wago_support_property=
		local wago_type wago_game_type_version invalid_version
		for type in "${!game_type_version[@]}"; do
			case $type in
				bcc) wago_type="bc" ;;
				wrath) wago_type="wotlk" ;;
				mists) wago_type="mop" ;;
				*) wago_type="$type"
			esac
			wago_game_type_version=
			IFS=':' read -ra V <<< "${game_type_version[$type]}"
			for version in "${V[@]}"; do
				# check the version
				if ! jq -e --arg t "$wago_type" --arg v "$version" '.[$t] | index($v)' <<< "$_wago_versions" &>/dev/null; then
					invalid_version="$version"
					# no match, so grab the next highest version (try to avoid testing versions)
					version=$( echo "$_wago_versions" | jq -r --arg t "$wago_type" --arg v "$invalid_version" '.[$t] | map(select(. < $v)) | max // empty' )
					if [[ -z $version ]]; then
						# just grab the highest version
						version=$( echo "$_wago_versions" | jq -r --arg t "$wago_type" '.[$t] | max // empty' )
					fi
					if [[ -z $version ]]; then
						echo "WARNING: No Wago game version match for \"$invalid_version\", ignoring" >&2
					else
						echo "WARNING: No Wago game version match for \"$invalid_version\", using \"$version\"" >&2
					fi
				fi
				if [[ -n $version && "$_wago_game_version," != *",$version," ]]; then
					wago_game_type_version+=",\"${version}\""
					_wago_game_version+=",${version}"
				fi
			done
			if [[ -n $wago_game_type_version ]]; then
				_wago_support_property+="\"supported_${wago_type}_patches\": [${wago_game_type_version#,}], "
			fi
		done
		_wago_game_version=$( echo "${_wago_game_version#,}" | tr ',' '\n' | sort -Vr | tr '\n' ',' )
		_wago_game_version=${_wago_game_version%,}
	fi
	if [ -z "$_wago_support_property" ]; then
		echo "Error fetching game version info from https://addons.wago.io/api/data/game"
		echo
		echo "Skipping upload to Wago."
		echo
		exit_code=1
		return 1
	fi

	local _wago_payload _wago_stability
	local resultfile result
	local return_code=0

	_wago_stability="$file_type"
	if [[ "$file_type" == "release" ]]; then
		_wago_stability="stable"
	fi

	_wago_payload=$( cat <<-EOF
	{
	  "label": "$archive_label",
	  $_wago_support_property
	  "stability": "$_wago_stability",
	  "changelog": $( jq --slurp --raw-input '.' < "$changelog_path" )
	}
	EOF
	)

	echo "Uploading $archive_name ($_wago_game_version $file_type) to https://addons.wago.io/addons/$wagoid"
	resultfile="$releasedir/wago_result.json"
	if result=$( echo "$_wago_payload" | curl -sS --retry 3 --retry-delay 10 \
			-w "%{http_code}" -o "$resultfile" \
			-H "authorization: Bearer $wago_token" \
			-H "accept: application/json" \
			-F "metadata=<-" \
			-F "file=@$archive" \
			"https://addons.wago.io/api/projects/$wagoid/version"
	); then
		case $result in
			200|201) echo "Success!" ;;
			302)
				echo "Error! ($result)"
				# don't need to ouput the redirect page
				return_code=1
				;;
			403)
				echo "Error! ($result)"
				return_code=1
				;;
			404)
				echo "Error! No Wago project for id \"$wagoid\" found."
				return_code=1
				;;
			*)
				echo "Error! ($result)"
				if [ -s "$resultfile" ]; then
					echo "$(<"$resultfile")"
				fi
				return_code=1
				;;
		esac
	else
		return_code=1
	fi
	echo

	rm -f "$resultfile" 2>/dev/null

	# shellcheck disable=SC2086
	return $return_code
}

# Create a GitHub Release for tags and upload the zipfile as an asset.
upload_github_asset() {
	local asset_id result return_code=0
	local _ghf_release_id=$1
	local _ghf_file_name=$2
	local _ghf_file_path=$3
	local _ghf_resultfile="$releasedir/gh_asset_result.json"
	local _ghf_content_type="application/${_ghf_file_name##*.}" # zip or json

	# check if an asset exists and delete it (editing a release)
	asset_id=$( curl -sS \
			-H "Accept: application/vnd.github.v3+json" \
			-H "Authorization: token $github_token" \
			"https://api.github.com/repos/$project_github_slug/releases/$_ghf_release_id/assets" \
		| jq --arg file "$_ghf_file_name"  '.[] | select(.name? == $file) | .id'
	)
	if [ -n "$asset_id" ]; then
		curl -s \
			-X DELETE \
			-H "Accept: application/vnd.github.v3+json" \
			-H "Authorization: token $github_token" \
			"https://api.github.com/repos/$project_github_slug/releases/assets/$asset_id" &>/dev/null
	fi

	echo -n "Uploading $_ghf_file_name... "
	if result=$( curl -sS --retry 3 --retry-delay 10 \
			-w "%{http_code}" -o "$_ghf_resultfile" \
			-H "Accept: application/vnd.github.v3+json" \
			-H "Authorization: token $github_token" \
			-H "Content-Type: $_ghf_content_type" \
			--data-binary "@$_ghf_file_path" \
			"https://uploads.github.com/repos/$project_github_slug/releases/$_ghf_release_id/assets?name=$_ghf_file_name"
	); then
		if [ "$result" = "201" ]; then
			echo "Success!"
		else
			echo "Error ($result)"
			if [ -s "$_ghf_resultfile" ]; then
				echo "$(<"$_ghf_resultfile")"
			fi
			return_code=1
		fi
	else
		return_code=1
	fi

	rm -f "$_ghf_resultfile" 2>/dev/null

	# shellcheck disable=SC2086
	return $return_code
}

upload_github() {
	if [[ -z "$tag" || -z "$project_github_slug" || -z "$github_token" ]]; then
		return 0
	fi

	local _gh_metadata _gh_previous_metadata _gh_payload _gh_release_url _gh_method
	local release_id versionfile resultfile result flavor title
	local return_code=0

	title=$( echo "$project" | jq --raw-input '.' )
	_gh_metadata='{ "name": '"$title"', "version": "'"$project_version"'", "filename": "'"$archive_name"'", "nolib": false, "metadata": ['
	for type in "${!game_type_interface[@]}"; do
		flavor="${game_flavor[$type]}"
		[[ $flavor == "retail" ]] && flavor="mainline"
		IFS=':' read -ra V <<< "${game_type_interface[$type]}"
		for interface in "${V[@]}"; do
			_gh_metadata+='{ "flavor": "'"${flavor}"'", "interface": '"${interface}"' },'
		done
	done
	_gh_metadata=${_gh_metadata%,}
	_gh_metadata+='] }'
	if [ -f "$nolib_archive" ]; then
		_gh_metadata+=',{ "name": '"$title"', "version": "'"$project_version"'", "filename": "'"$nolib_archive_name"'", "nolib": true, "metadata": ['
		for type in "${!game_type_interface[@]}"; do
			flavor="${game_flavor[$type]}"
			[[ $flavor == "retail" ]] && flavor="mainline"
			IFS=':' read -ra V <<< "${game_type_interface[$type]}"
			for interface in "${V[@]}"; do
				_gh_metadata+='{ "flavor": "'"${flavor}"'", "interface": '"${interface}"' },'
			done
		done
		_gh_metadata=${_gh_metadata%,}
		_gh_metadata+='] }'
	fi
	_gh_metadata='{ "releases": ['"$_gh_metadata"'] }'

	versionfile="$releasedir/release.json"
	jq -c '.' <<< "$_gh_metadata" > "$versionfile" || echo "There was an error creating release.json" >&2

	_gh_payload=$( cat <<-EOF
	{
	  "tag_name": "$tag",
	  "name": "$tag",
	  "body": $( jq --slurp --raw-input '.' < "$changelog_path" ),
	  "draft": false,
	  "prerelease": $( [[ "$file_type" != "release" ]] && echo true || echo false )
	}
	EOF
	)
	resultfile="$releasedir/gh_result.json"

	release_id=$( curl -sS \
			-H "Accept: application/vnd.github.v3+json" \
			-H "Authorization: token $github_token" \
			"https://api.github.com/repos/$project_github_slug/releases/tags/$tag" \
		| jq '.id // empty'
	)
	if [ -n "$release_id" ]; then
		echo "Updating GitHub release: https://github.com/$project_github_slug/releases/tag/$tag"
		_gh_release_url="https://api.github.com/repos/$project_github_slug/releases/$release_id"
		_gh_method="PATCH"

		# combine version info
		_gh_metadata_url=$( curl -sS \
				-H "Accept: application/vnd.github.v3+json" \
				-H "Authorization: token $github_token" \
				"https://api.github.com/repos/$project_github_slug/releases/$release_id/assets" \
			| jq -r '.[] | select(.name? == "release.json") | .url // empty'
		)
		if [ -n "$_gh_metadata_url" ]; then
			if _gh_previous_metadata=$( curl -sSL --fail \
					-H "Accept: application/octet-stream" \
					-H "Authorization: token $github_token" \
					"$_gh_metadata_url"
			); then
				jq -sc '.[0].releases + .[1].releases | unique_by(.filename) | { releases: [.[]] }' <<< "${_gh_metadata} ${_gh_previous_metadata}" > "$versionfile"
			else
				echo "Warning: Unable to update release.json ($?)"
			fi
		fi
	else
		echo "Creating GitHub release: https://github.com/$project_github_slug/releases/tag/$tag"
		_gh_release_url="https://api.github.com/repos/$project_github_slug/releases"
		_gh_method="POST"
	fi
	if result=$( echo "$_gh_payload" | curl -sS --retry 3 --retry-delay 10 \
			-w "%{http_code}" -o "$resultfile" \
			-H "Accept: application/vnd.github.v3+json" \
			-H "Authorization: token $github_token" \
			-X "$_gh_method" \
			-d @- \
			"$_gh_release_url"
	); then
		if [ "$result" = "200" ] || [ "$result" = "201" ]; then # edited || created
			if [ -z "$release_id" ]; then
				release_id=$( jq '.id' < "$resultfile" )
			fi
			upload_github_asset "$release_id" "$archive_name" "$archive"
			if [ -f "$nolib_archive" ]; then
				upload_github_asset "$release_id" "$nolib_archive_name" "$nolib_archive"
			fi
			if [ -s "$versionfile" ]; then
				upload_github_asset "$release_id" "release.json" "$versionfile"
			fi
		else
			echo "Error! ($result)"
			if [ -s "$resultfile" ]; then
				echo "$(<"$resultfile")"
			fi
			return_code=1
		fi
	else
		return_code=1
	fi
	echo

	rm -f "$resultfile" 2>/dev/null
	[ -z "$CI" ] && rm -f "$versionfile" 2>/dev/null

	# shellcheck disable=SC2086
	return $return_code
}


if [[ -z $skip_upload && -n $archive && -s $archive ]]; then
	if ! command -v jq &>/dev/null; then
		echo "Skipping upload because \"jq\" was not found."
		echo
		exit_code=1
	else
		retry upload_curseforge || exit_code=1
		upload_wowinterface || exit_code=1
		upload_wago || exit_code=1
		upload_github || exit_code=1
	fi
fi

# All done.

echo
echo "Packaging complete."
echo

# shellcheck disable=SC2086
exit $exit_code
