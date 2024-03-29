#!/bin/bash

PROGRAM_NAME="libchkr"
PROGRAM_VERSION="1.0.0"

OUTPUT_DIR=".libchkr"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

ASSETS_PATH="/usr/local/bin/libchkr_assets"
BOOTSTRAP_DIR="bootstrap-5.2.1"

BOOTSTRAP_JS="bootstrap.min.js"
BOOTSTRAP_CSS="bootstrap.min.css"
SIDEBAR_CSS="sidebar.css"

ICON_STATS=bar-chart-line.svg
ICON_EXE=boxes.svg
ICON_LIBS=box-fill.svg
ICON_WARN=exclamation-triangle.svg
ICON_SYST_INFO=gear.svg
ICON_GITHUB=github.svg

MAIN_CSS="main.css"

CUSTOM_JS="custom.js"

###### HTML functions ######

function html_create_warnings_section ()
{
	echo "<div id=\"report_warnings\" hidden=\"true\" class=\"report\"></div>"  >> "$OUTPUT_FILE"
}

function html_add_sidebar ()
{
	{
		echo "            <div id=\"sidebar\" class=\"d-flex flex-column flex-shrink-0 p-3 text-white bg-dark sticky-top\" style=\"width: 280px;\">"
		echo "                <a href=\"/\" class=\"d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none\">"
		echo "                    <svg class=\"bi me-2\" width=\"40\" height=\"32\"><use xlink:href=\"#bootstrap\"/></svg>"
		echo "                    <span class=\"fs-4\">$PROGRAM_NAME</span>"
		echo "                </a>"
		echo "                <hr>"
		echo "                <ul class=\"nav nav-pills flex-column mb-auto\">"
		echo "                    <li class=\"nav-item\">"
		echo "                        <a class=\"menu-link nav-link text-white\" aria-current=\"page\">"
		cat "$ASSETS_PATH/icons/$ICON_EXE"
		echo "                            Executables"
		echo "                        </a>"
		echo "                    </li>"
		echo "                    <li>"
		echo "                        <a class=\"menu-link nav-link text-white\">"
		cat "$ASSETS_PATH/icons/$ICON_LIBS"
		echo "                            Libraries"
		echo "                        </a>"
		echo "                    </li>"
		echo "                    <li>"
		echo "                        <a class=\"menu-link nav-link text-white\">"
		cat "$ASSETS_PATH/icons/$ICON_WARN"
		echo "                            Warnings"
		echo "                          <span id=\"menu_warn_nb\"class=\"badge rounded-pill text-bg-warning\">"
		echo "				</span>"
		echo "                        </a>"
		echo "                    </li>"
		echo "                    <li>"
		echo "                        <a class=\"menu-link nav-link text-white\">"
		cat "$ASSETS_PATH/icons/$ICON_STATS"
		echo "                            Statistics"
		echo "                        </a>"
		echo "                    </li>"
		echo "                    <li>"
		echo "                        <a class=\"menu-link nav-link text-white\">"
		cat "$ASSETS_PATH/icons/$ICON_SYST_INFO"
		echo "                            System informations"
		echo "                        </a>"
		echo "                    </li>"
		echo "                </ul>"
		echo "                <hr>"
		echo "                <div>"
		echo "                    <a href=\"https://github.com/mphschmitt/libchkr\" class=\"d-flex align-items-center text-white text-decoration-none\" id=\"repo_link\">"
		echo "                        <span width=\"32\" height=\"32\" class=\"rounded-circle me-2\">"
		cat "$ASSETS_PATH/icons/$ICON_GITHUB"
		echo "                        </span>"
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
		cat "$ASSETS_PATH"/"$BOOTSTRAP_DIR"/"$BOOTSTRAP_CSS"
		echo "        </style>"
		echo "        <style>"
		cat "$ASSETS_PATH"/"$MAIN_CSS"
		echo "        </style>"
		echo "        <style>"
		cat "$ASSETS_PATH"/"$SIDEBAR_CSS"
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
		cat "$ASSETS_PATH"/"$BOOTSTRAP_DIR"/"$BOOTSTRAP_JS"
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
	local BUTTON_CLASS
	local WARNS

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

	WARNS=${#UNDEF_SYMBOLS[@]}

	if [[ -n "${UNDEF_SYMBOLS[0]}" ]]
	then
		NB_OF_WARNINGS=$((NB_OF_WARNINGS+WARNS))
	fi

	BUTTON_CLASS="accordion-button collapsed"

	if [[ -n "${UNDEF_SYMBOLS[0]}" ]]
	then
		BUTTON_CLASS="$BUTTON_CLASS warning"
	fi

	{
		echo "<div class=\"elf accordion-item\" id=\"$ID\">"
		echo "	<h2 class=\"accordion-header\" id=\"$ID_HEADING\">"
		echo "		<button class=\"$BUTTON_CLASS\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#$ID_COLLAPSE\" aria-expanded=\"false\" aria-controls=\"$ID_COLLAPSE\">"
		if [[ -n "${UNDEF_SYMBOLS[0]}" ]]
		then
			echo "<span width=\"32\" height=\"32\" class=\"rounded-circle me-2\">"
			cat "$ASSETS_PATH/icons/$ICON_WARN"
			echo "</span>"
		fi
		echo "			$FILE_PATH"
		echo "		</button>"
		echo "	</h2>"
		echo "	<div id=\"$ID_COLLAPSE\" class=\"accordion-collapse collapse\" aria-labelledby=\"ID_HEADING\">"
		echo "		<div class=\"accordion-body\">"

		if [[ -n "${LIBS[0]}" ]]
		then
			echo "<h3 class=\"required_shared_objects\">Required Shared Objects: ${#LIBS[@]}</h3>"
			echo "<ul class=\"list-group\">"

			for lib in "${LIBS[@]}"
			do
				echo "<li class=\"list-group-item\">$lib</li>"
			done

			echo "              </ul>"
		fi

		if [[ -n "${UNDEF_SYMBOLS[0]}" ]]
		then
			echo "<h3 class=\"undef_symbols\" sym_nb=\"$WARNS\">Undefined symbols after code relocation: $WARNS</h3>"
			echo "<table class=\"table\">"

			echo "    <thead>"
			echo "        <tr>"
			echo "            <th scope=\"col\" style=\"width: 25%\">Symbol</th>"
			echo "            <th scope=\"col\" style=\"width: 25%\">Unmangled symbol</th>"
			echo "        </tr>"
			echo "    </thead>"
			echo "    <tbody>"

			for symbol in "${UNDEF_SYMBOLS[@]}"
			do
				local FORMATTED_SYMBOL
				local DEMANGLED_SYMBOL

				FORMATTED_SYMBOL=$(format_symbol "$symbol", "$FILE_PATH")
				DEMANGLED_SYMBOL=$(echo "$FORMATTED_SYMBOL" | c++filt)

				echo "<tr>"
				echo "    <td>$FORMATTED_SYMBOL</td>"
				echo "    <td>$DEMANGLED_SYMBOL</td>"
				echo "</tr>"
			done

			echo "    </tbody>"
			echo "</table>"
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
	NB_OF_FILES=$(ls -1 "$DIR_PATH" | wc -l)

	echo "Checking $NB_OF_FILES files in $DIR_PATH"
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

	NB_OF_ELF_FILES=$((NB_OF_ELF_FILES+1))

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
		echo "check ${file}"
		analyze_file "$file"
	done

	html_close_list
}

function analyze_file ()
{
	local TYPE
	local FILE_PATH

	FILE_PATH="$1"

	NB_OF_CHECKED_FILES=$((NB_OF_CHECKED_FILES+1))

	TYPE=$(file --brief "$1" | grep "shared object" )
	if [[ -n "$TYPE" ]]
	then
		analyse_elf "$FILE_PATH"
		return 0
	fi

	TYPE=$(file --brief "$FILE_PATH" | grep "directory" )
	if [[ -n "$TYPE" ]]
	then
		analyze_directory "$FILE_PATH"
		return 0
	fi

	return 0
}

function get_sys_info ()
{
	{
		echo "<table class=\"table\">"
		echo "    <tbody>"
		echo "        <tr>"
		echo "            <th scope=\"row\"></th>"
		echo "            <td>Cpu architecture</td>"
		echo "            <td>$(uname -p)</td>"
		echo "        </tr>"
		echo "        <tr>"
		echo "            <th scope=\"row\"></th>"
		echo "            <td>Machine Hardware</td>"
		echo "            <td>$(uname -m)</td>"
		echo "        </tr>"
		echo "        <tr>"
		echo "            <th scope=\"row\"></th>"
		echo "            <td>Hardware platform (OS compiled for)</td>"
		echo "            <td>$(uname -i)</td>"
		echo "        </tr>"
		echo "        <tr>"
		echo "            <th scope=\"row\"></th>"
		echo "            <td>Kernel name</td>"
		echo "            <td>$(uname -s)</td>"
		echo "        </tr>"
		echo "        <tr>"
		echo "            <th scope=\"row\"></th>"
		echo "            <td>Kernel version</td>"
		echo "            <td>$(uname -v)</td>"
		echo "        </tr>"
		echo "    </tbody>"
		echo "</table>"
	} >> "$OUTPUT_FILE"
}

###### Utilities functions ######

function print_version ()
{
	echo "$PROGRAM_NAME $PROGRAM_VERSION"
	echo ""
	echo "Copyright (C) 2022 Mathias Schmitt"
	echo "License: GNU Affero General Public License <https://gnu.org/licenses/agpl.html>."
	echo "This is free software, and you are welcome to change and redistribute it."
	echo "This program comes with ABSOLUTELY NO WARRANTY.";
}

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

	while true; do { \
		echo -ne "HTTP/1.0 200 OK\r\nContent-Length: $(wc -c < "$OUTPUT_FILE")\r\n\r\n"; \
		cat "$OUTPUT_FILE"; } | nc -l -p "$PORT" ; \
	done
}

# From https://github.com/dylanaraps/pure-bash-bible#strip-pattern-from-start-of-string
# Usage: lstrip "string" "pattern"
function lstrip () {
	printf '%s\n' "${1##$2}"
}

function format_symbol () {
	local SYMBOL
	local PATH

	SYMBOL="$1"
	PATH="($2),"

	SYMBOL=${SYMBOL%"$PATH"}
	SYMBOL=${SYMBOL#"undefined symbol: "}

	printf "$SYMBOL"
}

###### Main script ######

# Check number of arguments
if [[ "$#" -ne 0 ]]
then

	PORT=""
	TARGET=""
	NB_OF_CHECKED_FILES=0
	NB_OF_ELF_FILES=0
	NB_OF_WARNINGS=0

	for i in "$@"; do
		case $i in
		-p=*|--port=*)
			PORT="${i#*=}"
			if [[ -z "$PORT" ]]; then print_usage ; exit 1; fi
			shift # past argument=value
			;;
		-v|--verbose)
			;;
		-V|--version)
			print_version
			exit 0
			;;
		-h|--help)
			print_usage
			exit 0
			;;
		-*)
			echo "Unknown option $1"
			echo ""
			print_usage
			exit 1
			;;
		*)
			if [[ -n "$TARGET" ]]
			then
				echo "Error: Only one folder can be analyzed at one."
				echo ""
				print_usage
				exit 1
			fi

			TARGET="$i"
			;;
		esac
	done

	rm -rf "$OUTPUT_DIR"
	mkdir "$OUTPUT_DIR"
	touch "$OUTPUT_FILE"

	html_add_header "$OUTPUT_FILE"

	echo "<div id=\"report_sys_info\" hidden=\"true\" class=\"report\">" >> "$OUTPUT_FILE"
	get_sys_info
	echo "</div>" >> "$OUTPUT_FILE"

	echo "<div id=\"report_objects\" class=\"report\">" >> "$OUTPUT_FILE"
	analyze_file "$TARGET"
	echo "</div>" >> "$OUTPUT_FILE"

	html_create_warnings_section

	html_close

	echo ""
	echo "Summary:"
	echo "--------"
	echo "Checked $NB_OF_CHECKED_FILES files."
	echo "Found $NB_OF_ELF_FILES elf shared objects."
	echo "$NB_OF_WARNINGS symbols have not been found after function and data relocations."

	if [[ -n "$PORT" ]]
	then
		echo -e "\nThe result can be accessed at http://localhost:$PORT"
		run_server_on_port "$PORT"
	else
		echo -e "\nThe result can be accessed at $OUTPUT_FILE"
	fi

else
	echo "Error: No arguments."
	print_usage
	exit 1
fi

exit
