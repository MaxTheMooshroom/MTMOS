# MaxTheMooshroom's OS (MTMOS)
Current version: 0.0.1
 
This is an OS I'm creating for computercraft. Currently a WIP, I would not recommend installing yet, but feel free to peruse the code.

The intended use case is to allow for easy multi-processing. I want to be able to execute commands while simultaneously receiving messages from a network. 


### Installation
To install MTMOS, open a computercraft computer and type (or paste line by line) the following:
`lua`

`installer_data = http.get("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/master/installer").readAll()`

`installer = fs.open("installer", 'w')`

`installer.write(installer_data)`

`installer.close()`

`exit()`

`installer`

If you do not close the file by calling `installer.close()`, java will lock the file, so be sure not to forget that line!

### Current Commands
Currently the shell has the following available commands:

##### checkDependencies
`checkDependencies` verifies that all dependencies are installed. Any missing dependendies will be printed to the terminal.

##### clear
`clear` clears the terminal. The top line is reserved for notifications.

##### help
`help` prints a list of commands. In the future, `help <command>` will also be available to print help with a specific command.

##### installDependencies
`installDependencies` installs all missing dependencies.

##### installDependency
`installDependency <dependency>` installs the provided dependency if it is not already installed. 

##### loadDependencies
`loadDependencies` loads the installed dependencies in case they aren't loaded or haven't been reloaded since a local edit was made.

##### lua
`lua` opens the lua shell.
`lua <lua code>` executes the provided `lua_code`

example:

`lua print("hello")`

output:

`hello`

##### shell
`shell <shell command>` executes code on the CraftOS shell, as if you were directly using it.

example:

`shell rm junk_file`

removes the file `junk_file`

