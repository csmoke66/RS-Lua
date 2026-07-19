## Commands

### luaplugin 
Runs an installed lua plugin.
Examples:
```
luaplugin --list --all

; install and run a developer plugin
luaplugin --install devEntityHider
luaplugin devEntityHider
```

#### --list
Displays all available plugins.
##### Sub-options:
* -all
	* Displays all available plugins
#### --search
Searching for a plugin by text.
#### --install [plugin name]
Installs a plugin by name.
#### --installfromurl [.zip url]
Installs a plugin from a zip url.
#### --uninstall [plugin name]
Uninstalls an existing plugin.
##### Sub-options:
* --all
	* Uninstalls all plugins
* --keep-data
	* Keeps the physical script files on disk
#### --dev
Developer commands.
##### Sub-options:
* --restart
	* Restarts the lua VM
* --clear
	* Crashes my client