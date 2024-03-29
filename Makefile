# libchkr Analyze shared object and their dependencies.
# Copyright (C) 2022  Mathias Schmitt
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

SRC := libchkr.sh
PROG_NAME := libchkr
ASSETS_DIR := libchkr_assets
INSTALL_DIR := /usr/local/bin
ASSETS := assets

MOSES_PATH := moses

default: all

.PHONY: all
all: moses

re:
	@make clean -C ${MOSES_PATH}
	@make -C ${MOSES_PATH}

.PHONY: moses
moses:
	@make -C ${MOSES_PATH}


.PHONY: install
install:
	@make install -C ${MOSES_PATH}
	@cp ${SRC} ${INSTALL_DIR}/${PROG_NAME}
	@cp -r ${ASSETS} ${INSTALL_DIR}/${ASSETS_DIR}
	@chmod u+x,g+x,a+x ${INSTALL_DIR}/${PROG_NAME}
	@chmod u+r,g+r,a+r ${INSTALL_DIR}/${PROG_NAME}

.PHONY: uninstall
uninstall:
	@make uninstall -C ${MOSES_PATH}
	@rm -rf ${INSTALL_DIR}/${PROG_NAME}
	@rm -rf ${INSTALL_DIR}/${ASSETS_DIR}

.PHONY: help
help:
	@echo "Use one of the following targets:"
	@echo "  help      Print this help message"
	@echo "  install   Install discord_dl on your system"
	@echo "  uninstall Uninstall discord_dl on your system"
