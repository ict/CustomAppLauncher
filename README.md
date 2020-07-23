# ict's customizable silent application installer v1.5b

Note: This project was written in 2014. It has been uploaded here for historical
purposes and to make some slight changes.

## Purpose

Present the user with a list of Applications. The user selects the ones he wants
to install with simple checkboxes. The program then starts all checked setups (with
silent switches) one by one until everything is installed. Very simple ;)

Configuration:
Just edit the included launch.ini file. Refer to the sample file(s) for details.

General section
* `Title`: The GUI-Window's Title
* `SoftwarePerRow`: How Many checkboxes per Row
* `ExitafterInstall`: Set to 1 to auto-exit after Installing
* `TimeOut`: If set to 1, Install will automatically started after n seconds. Use with Checked=1 in Program sections for Auto-Installs.
* `PresetN`: Define presets that can be chosen from a menu

Program Sections:
* The Section title is the Program name that is displayed in the menu.
* `Command1`, `Command2` and `Command3` are the command(s) that will be executed. Just the first is required.
* `Checked=1` will activate the checkbox at startup
* `Preset` makes this entry active when a certain preset is chosen. Multiple presets can be configured by concatenating the numbers, e.g. `14` means the entry is active in preset 1 and 4

Usage:
Put launcher.exe and launch.ini in the same directory. Start launcher.exe

Notes:
You can only call `.exe`, `.com`, `.bat` or `.cmd` directly. So if you want to install `.msi`-Setups you 
have to use a `.cmd` file and put `start /wait setup.msi` in it.

When calling files in subdirectories, be aware that they are launched in the working
directory of the script. So if you have:

Root
|
|__launcher.exe
|
|__Unattended
    |
    |__setup.msi
    |__setup.cmd

You have to use "cd Unattended" as your first line in the `.cmd` or it won't
find setup.msi.

You can also use the `DiskLabel` option to let the launcher search for a removable drive
with a label **starting with** this text. You can then use the text `SOURCE_DRIVE` in your
commands. This will be replaced with the corresponding drive letter, e.g. `e:`.