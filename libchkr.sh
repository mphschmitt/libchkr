#!/bin/bash


PROGRAM_NAME="libchkr"
OUTPUT_DIR="/tmp/$PROGRAM_NAME"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

BOOTSTRAP_JS="bootstrap.min.js"
BOOTSTRAP_CSS="bootstrap.min.css"
ASSETS_PATH="/usr/local/bin/libchkr_assets"

BOOTSTRAP_SIDEBAR_CSS="bootstrap_sidebar.css"

MAIN_CSS="main.css"

CUSTOM_JS="custom.js"

###### HTML functions ######

function html_add_sidebar ()
{
	{
		echo "            <div class=\"d-flex flex-column flex-shrink-0 p-3 text-white bg-dark sticky-top\" style=\"width: 280px;\">"
		echo "                <a href=\"/\" class=\"d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none\">"
		echo "                    <svg class=\"bi me-2\" width=\"40\" height=\"32\"><use xlink:href=\"#bootstrap\"/></svg>"
		echo "                    <span class=\"fs-4\">$PROGRAM_NAME</span>"
		echo "                </a>"
		echo "                <hr>"
		echo "                <ul class=\"nav nav-pills flex-column mb-auto\">"
		echo "                    <li class=\"nav-item\">"
		echo "                        <a href=\"#\" class=\"nav-link\" aria-current=\"page\">"
		echo "                            <svg class=\"bi me-2\" width=\"16\" height=\"16\"><use xlink:href=\"#home\"/></svg>"
		echo "                            Executables"
		echo "                        </a>"
		echo "                    </li>"
		echo "                    <li>"
		echo "                        <a href=\"#\" class=\"nav-link text-white\">"
		echo "                            <svg class=\"bi me-2\" width=\"16\" height=\"16\"><use xlink:href=\"#speedometer2\"/></svg>"
		echo "                            Libraries"
		echo "                        </a>"
		echo "                    </li>"
		echo "                    <li>"
		echo "                        <a href=\"#\" class=\"nav-link text-white\">"
		echo "                            <svg class=\"bi me-2\" width=\"16\" height=\"16\"><use xlink:href=\"#table\"/></svg>"
		echo "                            Warnings"
		echo "                        </a>"
		echo "                    </li>"
		echo "                    <li>"
		echo "                        <a href=\"#\" class=\"nav-link text-white\">"
		echo "                            <svg class=\"bi me-2\" width=\"16\" height=\"16\"><use xlink:href=\"#grid\"/></svg>"
		echo "                            Statistics"
		echo "                        </a>"
		echo "                    </li>"
		echo "                </ul>"
		echo "                <hr>"
		echo "                <div>"
		echo "                    <a href=\"#\" class=\"d-flex align-items-center text-white text-decoration-none\" id=\"repo_link\">"
		echo "                        <img src=\"https://play-lh.googleusercontent.com/PCpXdqvUWfCW1mXhH1Y_98yBpgsWxuTSTofy3NGMo9yBTATDyzVkqU580bfSln50bFU\" alt=\"\" width=\"32\" height=\"32\" class=\"rounded-circle me-2\">"
		echo "                        <strong>Find us on Github</strong>"
		echo "                    </a>"
		echo "                </div>"
		echo "            </div>"
	} >> "$OUTPUT_FILE"
}

function html_add_header ()
{
	{
		echo "<!DOCTYPE html>"
		echo "<html>"

		echo "    <head>"
		echo "        <meta charset=\"utf-8\"></meta>"
		echo "        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
		echo "        <title>$PROGRAM_NAME</title>"
		echo "        <style>"
		cat "$ASSETS_PATH"/"$BOOTSTRAP_CSS"
		echo "        </style>"
		echo "        <style>"
		cat "$ASSETS_PATH"/"$MAIN_CSS"
		echo "        </style>"
		echo "        <style>"
		cat "$ASSETS_PATH"/"$BOOTSTRAP_SIDEBAR_CSS"
		echo "        </style>"
		echo "    </head>"

		echo "    <body>"
		echo "        <div class=\"main\">"
	} >> "$OUTPUT_FILE"

	html_add_sidebar

	{
		echo "            <div class=\"b-example-divider sticky-top\"></div>"
		echo "            <div>" # open second column
	} >> "$OUTPUT_FILE"
}

function html_close ()
{
	{
		echo "            <div>" # close second column
		echo "        <div>" # close main div
		echo "        <script>"
		cat "$ASSETS_PATH"/"$BOOTSTRAP_JS"
		echo "        </script>"
		echo "        <script>"
		cat "$ASSETS_PATH"/"$CUSTOM_JS"
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
	local ID_COLLAPSE
	local ID_HEADING
	local UNDEF_SYMBOLS
	local LIBS

	FILE_PATH="$1"

	#  md5sum adds an useless '-' character after the checksum, so we remove
	# it by splitting the string into an array and taking the first element.
	CHECKSUM=($(echo -n "$FILE_PATH" | md5sum))

	# We prepend a letter to the checksum because html ids must start with a
	# letter. Otherwise the id is not valid and javascript querySelectors
	# won't work.
	ID="A"${CHECKSUM[0]}

	ID_COLLAPSE="$ID-collapse"
	ID_HEADING="$ID-heading"

	DEPENDENCIES="$2"

	OLD_IFS="$IFS"
	IFS=$'\n'
	UNDEF_SYMBOLS=($( echo "$DEPENDENCIES" | grep "undefined symbol"))
	LIBS=($(echo "$DEPENDENCIES" | grep -v "undefined symbol"))
	IFS="$OLD_IFS"


	{
		echo "<div class=\"accordion-item\" id=\"$ID\">"
		echo "	<h2 class=\"accordion-header\" id=\"$ID_HEADING\">"
		echo "		<button class=\"accordion-button\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#$ID_COLLAPSE\" aria-expanded=\"false\" aria-controls=\"$ID_COLLAPSE\">"
		echo "			$FILE_PATH"
		echo "		</button>"
		echo "	</h2>"
		echo "	<div id=\"$ID_COLLAPSE\" class=\"accordion-collapse collapse\" aria-labelledby=\"ID_HEADING\">"
		echo "		<div class=\"accordion-body\">"

		if [[ -n "${LIBS[0]}" ]]
		then
				echo "<h3>Required Shared Objects: ${#LIBS[@]}</h3>"
				echo "<ul class=\"list-group\">"

			for lib in "${LIBS[@]}"
			do
				echo "<li class=\"list-group-item\">$lib</li>"
			done

			echo "              </ul>"
		fi

		if [[ -n "${UNDEF_SYMBOLS[0]}" ]]
		then
				echo "<h3>Undefined symbols after code relocation: ${#UNDEF_SYMBOLS[@]}</h3>"
				echo "<ul class=\"list-group\">"

			for symbol in "${UNDEF_SYMBOLS[@]}"
			do
				echo "<li class=\"list-group-item\">$symbol</li>"
			done

			echo "              </ul>"
		fi
		echo "		</div>"
		echo "	</div>"
		echo "</div>"
	} >> "$OUTPUT_FILE"
}

function html_open_list ()
{
	echo "<div class=\"accordion\" id=\"objects_list\">" >> "$OUTPUT_FILE"
}

function html_close_list ()
{
	echo "</div>" >> "$OUTPUT_FILE"
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

	FILE_PATH="$1"
	html_add_file_infos "$1" "$(ldd -r "$1")"
	return 0
}

function analyze_directory ()
{
	local DIR_PATH

	DIR_PATH="$1"

	if is_directory_empty "$DIR_PATH"; then return; fi

	html_open_list

	for file in "$DIR_PATH"/*
	do
		echo "file: ${file}"
		analyze_file "$file"
	done

	html_close_list
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

	return 0
}

###### Utilities functions ######

function print_usage ()
{
	echo "Usage: libchkr"
	echo "  $PROGRAM_NAME [options] <folder>"
	echo "Options"
	echo "  <folder>        The name of the folder to analyze."
	echo "  -v              Verbose output."
	echo "  -V              Print version and exit."
	echo "  -h              Print this help message and exit."
	echo "  -p              The port used to access the report."
}

function run_server_on_port ()
{
	local PORT

	PORT="$1"

	echo ""
	echo "The result can be accessed at htpp://localhost:$PORT"

	while true; do { \
		echo -ne "HTTP/1.0 200 OK\r\nContent-Length: $(wc -c < "$OUTPUT_FILE")\r\n\r\n"; \
		cat "$OUTPUT_FILE"; } | nc -l -p "$PORT" ; \
	done
}

###### Main script ######

# Check number of arguments
if [[ "$#" -ne 0 ]]
then

	PORT=""
	TARGET=""

	for i in "$@"; do
		case $i in
		-p=*|--port=*)
			PORT="${i#*=}"
			if [[ -z "$PORT" ]]; then print_usage ; exit 1; fi
			shift # past argument=value
			;;
		-v|--verbose)
			;;
		-V|--Version)
			;;
		-h|--help)
			print_usage
			exit 0
			;;
		-*|--*)
			echo "Unknown option $1"
			echo ""
			print_usage
			exit 1
			;;
		*)
			TARGET="$i"
			;;
		esac
	done

	mkdir "$OUTPUT_DIR"
	touch "$OUTPUT_FILE"

	html_add_header "$OUTPUT_FILE"

	analyze_file "$1"

	html_close

	if [[ -n "$PORT" ]]
	then
		run_server_on_port "$PORT"
	fi

else
	echo "Error: No arguments."
	print_usage
	exit 1
fi

exit
