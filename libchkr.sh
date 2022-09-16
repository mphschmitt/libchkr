#!/bin/bash


PROGRAM_NAME="libchkr"
OUTPUT_DIR="/tmp/$PROGRAM_NAME"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

SHARED_OBJECT="SHARED_OBJECT"
DIRECTORY="DIRECTORY"
UNFIT="UNFIT"

function html_add_header ()
{
	echo "<html>" >> "$OUTPUT_FILE"
	echo "    <head>" >> "$OUTPUT_FILE"
	echo "    </head>" >> "$OUTPUT_FILE"
	echo "    <body>" >> "$OUTPUT_FILE"

}

function html_close ()
{
	echo "    </body>" >> "$OUTPUT_FILE"
	echo "</html>" >> "$OUTPUT_FILE"
}

function print_usage ()
{
	echo "libckr"
	echo "Usage"
	echo "  $PROGRAM_NAME [options] <folder>"
	echo ""
	echo "Options"
	echo "  <folder>        The name of the folder to analyze."
	echo "  -v              Verbose output."
	echo "  -V              Print version and exit."
}

function is_directory_empty ()
{
	local NB_OF_FILES

	NB_OF_FILES=$(ls -1 $1 | wc -l)
	echo "There are $NB_OF_FILES in the directory $1"
	if [[ "$NB_OF_FILES" -eq 0 ]]
	then
		true; return
	fi

	false
}

function get_dependecies ()
{
	local DEPS

	DEPS=$(ldd -r "$1")
	echo "${DEPS}"
	return 0
}

function analyze_directory ()
{
	if is_directory_empty "$1"; then return; fi

	for file in "$1"/*
	do
		echo "file: ${file}"
		analyze_file "$file"
	done
}

function analyze_file ()
{
	local TYPE

	TYPE=$(file "$1" | grep "shared object" )
	if [[ -n "$TYPE" ]]
	then
		get_dependecies "$1"
		return 0
	fi

	TYPE=$(file "$1" | grep "directory" )
	if [[ -n "$TYPE" ]]
	then
		analyze_directory "$1"
		return 0
	fi

	echo "$UNFIT"
	return 0
}

# Check number of arguments
if [[ "$#" -eq 1 ]]
then

	mkdir "$OUTPUT_DIR"
	touch "$OUTPUT_FILE"

	html_add_header "$OUTPUT_FILE"

	analyze_file "$1"

else
	echo "Error: No arguments."
	print_usage
	exit 1
fi

exit

while true; do { \
  echo -ne "HTTP/1.0 200 OK\r\nContent-Length: $(wc -c <index.html)\r\n\r\n"; \
  cat index.html; } | nc -l -p 8080 ; \ 
done
