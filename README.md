# WinScript Runner
## Initial warning:
This tool is an experimental project created to simplify the execution of multiple scripts. Please note that I do not take responsibility for any potential damages caused by the scripts.

## Overview:
WinScript Runner is a simple tool designed to simplify the execution and management of scripts on Windows systems. It provides a interface for 
executing scripts efficiently and flexibility to add more scripts. The main focus in this aplication is to run windows modification scripts, but can be used as any type of .bat file menu.<br>
This overview will cover the program's functionalities and how scripts and related files are distributed within its directory structure.


## Features and Implementations:
* <b>Setup</b>:<br>
WinScript Runner includes a initial setup that do essential tasks such as copying and configuring auxiliary .txt files, deleting archives, and updating the auxiliar folder (located in "%temp%\WinsdowScript_runner"). 
These operations are crucial since the menu can adaptate with the addition or deletion of modules and scripts because of the setup. 

* <b>Main Menu</b>:<br>
The main menu serves as the central navigation hub within WinScript Runner. It provides an overview of available modules and access to other menus for script management and execution.

* <b>Modules Menu</b>:<br>
Within the modules menu, users can select specific modules that contain scripts they intend to execute. This menu offers flexibility by allowing users to execute scripts selectively or run all scripts within a chosen module.

* <b>Script Menu</b>:<br>
The script menu provides detailed information about individual scripts within selected modules. It includes options to execute the script, undo changes made by the script (if an undo script is provided),
and view a description of the script (if a description file is available).

## File distribuition explanation:
The files associated with WinScript Runner are organized within specific directories under the main program directory, providing the structure to all this program. Here's a breakdown of the file distribution:

* Main Directory:<br>
This is the root directory where WinScript Runner and its associated files are located.

* Ascii arts Directory:<br>
Contains ASCII art .txt files used within the program. These files enhance the visual presentation of the interface..

* Script Directory:

This directory houses various modules folders, each containing scripts related to specific functionalities or tasks. These modules are located in `MainDirectory\scripts\{Module-Name}`.

* Script-Specific Directories:
Each script is located within its respective folder under the modules directory. located in `MainDirectory\scripts\{Module-Name}\{ScriptFolder}`. This folder content the following files:

  * `do.bat`:
  An essential file required to execute the script. It must be present for the script to run.
  * `undo.bat`:
  Optional file. If present, allows users to undo changes made by the script. If absent, the undo option does not appear in the script menu.
  * `title.txt`:
  Optional file. If present, displays the script's title in the module menu. If absent, the folder name is shown instead.
  * `description.txt`:
  Optional file. If present, provides a description of the script in the script menu. If absent, a default "there is no description" text is displayed.

###### To add more scripts and modules you need to keep this structure and never create a folder with space in the name
###### When setup runs, a copy of all archives are made in auxiliar folder to make the acess with admin rights more easy.

## Future Modifications:
To enhance user experience with WinScript Runner, there are some ideas of new features: 
  * One significant enhancement for WinScript Runner would be the implementation of an "Add Script" tool. This tool would provide a straightforward method to incorporate new scripts into the existing framework with less troble.
  * Tracking and Managing Run Scripts with Undo Capability:
     * Highlight scripts that have associated undo scripts (undo.bat) in the Script Menu for easy identification.
     * Enhance the script menu interface to clearly indicate which scripts have been executed and offer the option to undo changes.
     * Create a type of script that doesn't need a undo capability. This type can remove the warning message when the undo.bat is ausent and change the "do" option to "run". This adjustment can make the menu more polished and better suited for other usage scenarios.
  * Improve the management of the initial setup, as all files currently need to be copied to the auxiliary folder, which can result in slow startup times, especially on hard drives. If possible, change the current logic of copying everything to the auxiliary folder to instead create references to the actual file paths used by the program or another alternative, avoiding the need to copy all files.

