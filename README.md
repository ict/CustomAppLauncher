# Customizable Application Launcher

Note: This project some time in 2006. It has been uploaded here for historical
purposes and to make some slight changes.

## Purpose

Present the user with a list of Applications. The user selects the ones he wants
to launch with simple checkboxes. The program then starts all checked commands 
one by one until everything has launched and exited.

This is intended as a quick application install menu, similar to [Ninite](https://ninite.com/).

Configuration:
Just edit the included launch.ini file. Refer to the sample file(s) for details.

General section
* `Title`: The GUI-Window's Title
* `SoftwarePerRow`: How many checkboxes to display per row
* `ExitafterInstall`: Set to 1 to auto-exit after Installing
* `TimeOut`: If set to a positive number, launching will automatically start after this number of seconds. Use with `Checked=1` in program sections for automatic launches
* `PresetN`: Define presets that can be chosen from a menu

Program Sections:
* The section title is the program name that is displayed in the menu.
* `Command1`, `Command2` and `Command3` are the command(s) that will be executed. Just the first is required.
* `Checked=1` will activate the checkbox at startup
* `Preset` makes this entry active when a certain preset is chosen. Multiple presets can be configured by concatenating the numbers, e.g. `14` means the entry is active in preset 1 and 4

## Usage
Put launcher.exe and launch.ini in the same directory. Start launcher.exe

Notes:
You can only call `.exe`, `.com`, `.bat` or `.cmd` directly. So if you want to install `.msi`-Setups you 
have to use a `.cmd` file and put `start /wait setup.msi` in it.

When calling files in subdirectories, be aware that they are launched in the working
directory of the script. So if you have:

```
Root
|
|__launcher.exe
|
|__Unattended
    |
    |__setup.msi
    |__setup.cmd
```

You have to use `cd Unattended` as your first line in the `.cmd` or it won't
find setup.msi.

You can also use the `DiskLabel` option to let the launcher search for a removable drive
with a label **starting with** this text. You can then use the text `SOURCE_DRIVE` in your
commands. This will be replaced with the corresponding drive letter, e.g. `e:`.
