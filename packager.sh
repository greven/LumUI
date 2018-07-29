root_dir=../../..
top_dir=.
release_dir=.release
checkout_dir="$release_dir/.checkout"
addons_dir="$release_dir/Interface/AddOns"

basedir=$( cd "$topdir" && pwd )
basedir=${basedir##/*/}

# Help functions
parse_yaml() {
  local yaml_file=$1
  local prefix=$2
  local s
  local w
  local fs

  s='[[:space:]]*'
  w='[a-zA-Z0-9_.-]*'
  fs="$(echo @|tr @ '\034')"

  (
      sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/\s*$//g;' \
          -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
          -e  "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
          -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |

      awk -F"$fs" '{
          indent = length($1)/2;
          if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
          vname[indent] = $2;
          for (i in vname) {if (i > indent) {delete vname[i]}}
              if (length($3) > 0) {
                  vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                  printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
              }
          }' |
          
      sed -e 's/_=/+=/g' |
      awk 'BEGIN {
                FS="=";
                OFS="="
            }
            /(-|\.).*=/ {
                gsub("-|\\.", "_", $1)
            }
            { print }'

  ) < "$yaml_file"
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
	si_project_abbreviated_hash=$( git -C "$si_repo_dir" show --no-patch --format="%h" 2>/dev/null )
	si_project_author=$( git -C "$si_repo_dir" show --no-patch --format="%an" 2>/dev/null )
	si_project_timestamp=$( git -C "$si_repo_dir" show --no-patch --format="%at" 2>/dev/null )
	si_project_date_iso=$( date -ud "@$si_project_timestamp" -Iseconds 2>/dev/null )
	si_project_date_integer=$( date -ud "@$si_project_timestamp" +%Y%m%d%H%M%S 2>/dev/null )
	# XXX --depth limits rev-list :\ [ ! -s "$(git rev-parse --git-dir)/shallow" ] || git fetch --unshallow --no-tags
	si_project_revision=$( git -C "$si_repo_dir" rev-list --count $si_project_hash 2>/dev/null )

	# Get the tag for the HEAD.
	si_previous_tag=
	si_previous_revision=
	_si_tag=$( git -C "$si_repo_dir" describe --tags --always 2>/dev/null )
	si_tag=$( git -C "$si_repo_dir" describe --tags --always --abbrev=0 2>/dev/null )
	# Set $si_project_version to the version number of HEAD. May be empty if there are no commits.
	si_project_version=$si_tag
	# The HEAD is not tagged if the HEAD is several commits past the most recent tag.
	if [ "$si_tag" = "$si_project_hash" ]; then
		# --abbrev=0 expands out the full sha if there was no previous tag
		si_project_version=$_si_tag
		si_previous_tag=
		si_tag=
	elif [ "$_si_tag" != "$si_tag" ]; then
		si_project_version=$_si_tag
		si_previous_tag=$si_tag
		si_tag=
	else # we're on a tag, just jump back one commit
		si_previous_tag=$( git -C "$si_repo_dir" describe --tags --abbrev=0 HEAD~ 2>/dev/null )
	fi
}

set_info_git "$top_dir"

# Set some version info about the project
tag=$si_tag
project_version=$si_project_version
previous_version=$si_previous_tag
project_hash=$si_project_hash
project_revision=$si_project_revision
previous_revision=$si_previous_revision
project_timestamp=$si_project_timestamp
project_github_url=${si_repo_url%.git}

# Packaging functions

read_addons() {
  local file=$1
  eval $(parse_yaml $file) # create variables
}

fetch_git_asset() {
  wget https://github.com/$(wget $1/releases/latest -O - | egrep '/.*/.*/.*zip' -o) -P "$checkout_dir/$name"
  unzip "$checkout_dir/$name/*.zip" -d "$checkout_dir"
  rm -v "$checkout_dir/$name"/*.zip
}

get_addon() {
  local name=$1
  local url=$2
  local type=$3 

  if [ "$type" = "master" ]; then
    git clone -q --depth 1 "$url" "$checkout_dir/$name"
  elif [ "$type" = "tag" ]; then
    git clone -q --depth 50 "$url" "$checkout_dir/$name"
    if [ $? -ne 0 ]; then return 1; fi
    local tag=$( git -C "$checkout_dir/$name" for-each-ref refs/tags --sort=-taggerdate --format=%\(refname:short\) --count=1 )
    if [ -n "$tag" ]; then
			echo "Fetching tag \"$tag\" from external $url"
			git -C "$checkout_dir/$name" checkout -q "$tag"
		else
			echo "Fetching latest version of external $url"
		fi
  elif [ "$type" = "zip" ]; then
    fetch_git_asset $url $name
  elif [ "$type" = "folder" ]; then
    svn export -q $url "$checkout_dir/$name"
    echo "Checked out $name"
	fi

  # Move the checkout into the AddOns folder
  echo "Move .checkout/$name to AddOns folder"
  mv "$checkout_dir/$name" "$addons_dir"

}

download_addons() {
  read_addons "addons.yml"
  local COUNT=${#addons__name[*]}

  for (( i=0; i<${COUNT}; i++ )); do
    local name=${addons__name[$i]}
    local url=${addons__url[$i]}
    local type=${addons__type[$i]}
    get_addon $name $url $type
  done
  rm -rf $checkout_dir
}

copy_directory_tree() {
  echo "Copying files into $addons_dir/LumUI"
  if [ ! -d "$addons_dir" ]; then
		mkdir -p "$addons_dir/LumUI"
	fi

  cp -R $(ls | grep -v '^.release$') $addons_dir/LumUI/
}

copy_fonts() {
 cp -r $root_dir/Fonts $release_dir/Fonts
}

zip_release() {
  package=$basedir
  archive_package_name="${package//[^A-Za-z0-9._-]/_}"
  archive_version="$project_version"
	archive_name="$archive_package_name-$archive_version.zip"
	archive="$release_dir/$archive_name"

  echo "Creating archive: $archive_name"

	if [ -f "$archive" ]; then
		rm -f "$archive"
	fi
	( cd "$release_dir" && zip -X -r "$archive_name" . )

	if [ ! -f "$archive" ]; then
		exit 1
	fi
	echo
}

package() {
  copy_directory_tree
  copy_fonts
  download_addons
  zip_release
}

package