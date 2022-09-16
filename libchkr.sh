#!/bin/bash


PROGRAM_NAME="libchkr"
OUTPUT_DIR="/tmp/$PROGRAM_NAME"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

SHARED_OBJECT="SHARED_OBJECT"
DIRECTORY="DIRECTORY"
UNFIT="UNFIT"

BOOTSTRAP_JS="bootstrap.min.js"
BOOTSTRAP_CSS="bootstrap.min.css"
BOOTSTRAP_PATH="/usr/local/bin/libchkr_assets"

###### HTML functions ######

function html_add_header ()
{
	local BOOTSTRAP_CSS_TXT

	BOOTSTRAP_CSS_TXT=$(cat "$BOOTSTRAP_PATH"/"$BOOTSTRAP_CSS")
	{
		echo "<!DOCTYPE html>"
		echo "<html>"
		echo "    <head>"
		echo "        <meta charset=\"utf-8\"></meta>"
    		echo "        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
		echo "        <title>$PROGRAM_NAME</title>"
		echo "        <style>"
		echo "            $BOOTSTRAP_CSS_TXT"
		echo "        </style>"
		echo "    </head>"
		echo "    <body>"
	} >> "$OUTPUT_FILE"
}

function html_close ()
{
	local BOOTSTRAP_JS_TXT

	BOOTSTRAP_JS_TXT=$(cat "$BOOTSTRAP_PATH"/"$BOOTSTRAP_JS")

	{
		echo "        <script>"
		echo "            $BOOTSTRAP_JS_TXT"
		echo "        </script>"
		echo "    </body>"
		echo "</html>"
	} >>  "$OUTPUT_FILE"
}

function html_add_file_infos ()
{
	local ID
	local FILE_PATH
	local DEPENDENCIES
	local CHECKSUM

	FILE_PATH="$1"
	CHECKSUM=($(echo -n "$FILE_PATH" | md5sum)) # md5sum adds an useless '-' character after the checksum
	ID=${CHECKSUM[0]}
	DEPENDENCIES="$2"

	echo "$DEPENDENCIES"
	printf "       <div id=$ID path=$1>\n        <p>$DEPENDENCIES</p>\n         </div>\n" >> "$OUTPUT_FILE"
}

###### Analysis functions ######

function is_directory_empty ()
{
	local DIR_PATH
	local NB_OF_FILES

	DIR_PATH="$1"
	NB_OF_FILES=$(ls -1 $DIR_PATH | wc -l)

	echo "There are $NB_OF_FILES in the directory $DIR_PATH"
	if [[ "$NB_OF_FILES" -eq 0 ]]
	then
		true; return
	fi

	false
}

function analyse_elf ()
{
	local FILE_PATH
	local DEPENDENCIES

	FILE_PATH="$1"
	DEPENDENCIES=$(ldd -r "$1")

	html_add_file_infos "$1" "$DEPENDENCIES"
	return 0
}

function analyze_directory ()
{
	local DIR_PATH

	DIR_PATH="$1"

	if is_directory_empty "$DIR_PATH"; then return; fi

	for file in "$DIR_PATH"/*
	do
		echo "file: ${file}"
		analyze_file "$file"
	done
}

function analyze_file ()
{
	local TYPE
	local FILE_PATH

	FILE_PATH="$1"

	TYPE=$(file "$1" | grep "shared object" )
	if [[ -n "$TYPE" ]]
	then
		analyse_elf "$FILE_PATH"
		return 0
	fi

	TYPE=$(file "$FILE_PATH" | grep "directory" )
	if [[ -n "$TYPE" ]]
	then
		analyze_directory "$FILE_PATH"
		return 0
	fi

	echo "$UNFIT"
	return 0
}

###### Utilities functions ######

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
	echo "  -h              Print this help message and exit."
	echo "  -p              The port used to access the report."
}

###### Main script ######

# Check number of arguments
if [[ "$#" -eq 1 ]]
then

	mkdir "$OUTPUT_DIR"
	touch "$OUTPUT_FILE"

	html_add_header "$OUTPUT_FILE"

	analyze_file "$1"

	html_close

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
