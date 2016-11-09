# This functions adds elements to the given array.
# USAGE: bashutils.array.add_to_array <array_name> <element...>
# RETURN: 0 (true), 1 (false)
function bashutils.array.add_to_array()
{
	local array_name=$1
	local val
	shift
	for ((i=1; i<=$#; i++)); do
		val="${!i}"
		eval "${array_name}+=( \"\${val[@]}\" )"
	done
	return 0
}

# This function removes the specified element from the array.
# USAGE: bashutils.array.remove_from_array <array_name> <needle> [strict]
# RETURN: 0 (succeeded), 1 (failed)
function bashutils.array.remove_from_array()
{
	if [ -z "$2" ]; then
		return 1
	fi

	local array_name=$1
	eval "local -i elems=\"\${#${array_name}[@]}\""

	if [ $elems -eq 0 ]; then
		return 1
	fi

	local -i remove_index

	# by index
	if bashutils.type.is_integer "$2" ; then
		if [ ! $2 -ge 0 ]; then
			return 1
		fi
		remove_index=$2
	else
		# by name
		remove_index=$(bashutils.array.find_index_in_array "$array_name" "$2" "$3")
		if [ $? -ne 0 ]; then
			return 1
		fi
	fi

	# remove
	eval "local -a tmp_array=( \"\${${array_name}[@]}\" )"
	tmp_array=( "${tmp_array[@]:0:$remove_index}" "${tmp_array[@]:$(expr $remove_index + 1)}" )
	bashutils.array.set_array "$1" "${tmp_array[@]}"
}

# This function returns the index of the element specified.
# USAGE: bashutils.array.find_index_in_array <array_name> <needle> [strict]
# RETURN: 0 (true), 1 (false)
function bashutils.array.find_index_in_array()
{
	if ! bashutils.array.in_array "$1" "$2" "${3:-1}"; then
		return 1
	fi

	eval "local -a tmp=( \"\${${1}[@]}\" )"
	for ((i=0; i<${#tmp[@]}; i++)); do
		if [[ "${tmp[$i]}" =~ ^$2.* ]]; then
			echo "$i"
			return 0
		fi
	done

	return 1
}

# This function prepends the given elements to the specified array.
# USAGE: bashutils.array.prepend_to_array <array_name> <element...>
# RETURN: 0 (true), 1 (false)
function bashutils.array.prepend_to_array()
{
	local array_name=$1
	shift
	eval "local -a array_to_copy=( \"\${${array_name}[@]}\" )"
	bashutils.array.set_array "$array_name" "$@"
	bashutils.array.add_to_array "${array_name}" "${array_to_copy[@]}"
}

# This function assigns the given elements to the specified array.
# USAGE: bashutils.array.set_array <array_name> <element...>
# RETURN: 0 (true), 1 (false)
function bashutils.array.set_array()
{
	local array_name=$1
	shift
	eval "$array_name=()"
	bashutils.array.add_to_array "${array_name}" "$@"
}

# This function returns the elements of the given array in case of subshell
# assignment or stores them in a new variable if specified in argument 2.
# USAGE: bashutils.array.get_array <array_name> [other_array_name]
# RETURN: 0 (true), 1 (false)
function bashutils.array.get_array()
{
	if [ -z "$2" ]; then
		if [ ! -z $BASH_SUBSHELL ] && [ $BASH_SUBSHELL -gt 0 ]; then
			eval "echo \"\${${1}[@]}\""
			return 0
		fi
		return 1
	fi

	eval "$2=( \"\${${1}[@]}\" )"
}

# This function pops elements from the given array, if argument 2 is an integer
# then it will pop as many times as specified.
# USAGE: bashutils.array.array_pop <array_name> [number_of_times]
# RETURN: 0 (true), 1 (false)
function bashutils.array.array_pop()
{
	local array_name=$1
	local -i elems=${2:-1}
	eval "local -a array_to_copy=( \"\${${array_name}[@]:$elems}\" )"
	bashutils.array.set_array "$array_name" "${array_to_copy[@]}"
}

# This function checks if the element exists in the given array.
# USAGE: bashutils.array.in_array <array_name> <element> [strict]
# RETURN: 0 (true), 1 (false)
function bashutils.array.in_array()
{
	eval "local -a array=( \"\${${1}[@]}\" )"
	local strict=${3:-1}
	for ((i=0; i<${#array[*]}; i++)); do
		if [[ "$strict" == "1" ]] && [[ "${array[$i]}" == $2 ]]; then
			return 0
		elif [[ "$strict" == "0" ]] && [[ "${array[$i]}" =~ ^$2.* ]]; then
			return 0
		fi
	done
	return 1
}


