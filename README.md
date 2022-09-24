# Table of Contents

- [About the project](#libchkr)
	- [Build and install](#build-and-install)
	- [Uninstall](#uninstall)
	- [Usage](#usage)
- [How does it work](#how-does-it-work)
- [License](#license)
- [Contact](#contact)

# libchkr

libchkr is a tool designed to analyse a project executables and shared libraries.
It agregates information about the elf objects using various utilities, display them in a user-friendly html file, and report errors, warnings and statistics.     

Its main use is to discover symbols that are referenced by an object, but are not defined anywhere in itself and its dependencies, and do so before product delivery. It can also report cpu architecture mismatch, unkown dependency path, etc...

# Build and install

Install dependencies (fedora):
```
sudo dnf install glibc-common netcat
```
    
Install dependencies (debian/ubuntu):    
```
sudo apt-get install libc-bin netcat
```

Build the project:
```
make
```

Install:
```
sudo make install
```

By default, libchkr is installed in `/usr/local/bin/libchkr`  and its dependencies are installed in `/usr/local/bin/libchkr_assets`.

# Uninstall

```
sudo make uninstall
```

# Usage

libchkr takes a directory as an arguments and will scan its content, looking for ELF shared objects.    
It then performs various operations on them to gain knowledge about the symbols they export, their dependencies, their dwarf debugging informations, and so on...    

To scan a directory:    
```
libchkr <directory-path>
```

libchkr will create a *.libchkr* hidden directory in the directory libchkr was launched from.    
It will contain an index.html file, which is completly self-contained (so no internet connection is required), which can then be opened with a web browser.    

The html analysis report can be served by a netcat webserver by specifying a port to libchkr:    
```
libchkr --port=8080 <directory-path>
```

The report can then be accessed at localhost:port in a web browser. This can be useful while analyzing a project on a remote machine.

To obtain help, you can type:
```
libchkr --help
```

A manual is also installed for each tool in both english and french in `/usr/local/share/man`. It can be consulted with the following commands:
```
man libchkr
```

# How does it work

# License

# Contact

Mathias Schmitt - mathiaspeterhorst@gmail.com     

Project link: https://github.com/mphschmitt/libchkr
