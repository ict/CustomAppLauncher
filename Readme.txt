ict's customizable silent application installer v1.5b
====

Purpose:

Present the user with a list of Applications. The user selects the ones he wants
to install with simple checkboxes. The program then starts all checked setups (with
silent switches) one by one until everything is installed. Very simple ;)

Configuration:
Just edit the included launch.ini file:

General section
	Title: The GUI-Window's Title
	SoftwarePerRow: How Many checkboxes per Row
	ExitafterInstall: Set to 1 to auto-exit after Installing
	TimeOut: If != 0, Install will automatically started after n seconds.
		 (Use with Checked=1 in Program sections for Auto-Installs.)

Program Sections:
	The Section title is the Program name that is displayed in the menu.
	Command1 - 3 are the command(s) that will be executed. Just one is neccessary.
	Checked=1 will activate the checkbox at startup
	ToolTip=Your Text will display a tooltip with the specified text when the mouse
		is hovered over the entry.

Usage:
Put launcher.exe and launch.ini in the same directory. Start launcher.exe

Notes:
You can only call .exe, .com, .bat, .cmd directly. So if you want to install .msi-Setups you 
have to use a .cmd file and put "start /wait setup.msi /qb" in it.

When calling .cmd files in subdirectories, be aware that they are launched in the working
directory of the script. So if you have:

CD-Root
|
|__launcher.exe
|
|__Unattended
    |
    |__setup.msi
    |__setup.cmd

You have to use "cd Unattended" as your first line in the .cmd or it won't
find setup.msi.

That's it.

Contact me: ict1986(at)gmail.com