Installation instructions
=========================

This chapter describes the various methods for installing Network UPS Tools.

Whenever it is possible, prefer <<Installing_packages, installing from packages>>.
Packagers have done an excellent and hard work at improving NUT integration
into their operating system.  On the other hand, distributions and appliances
tend to package "official releases" of projects such as NUT, and so do not
deliver latest and greatest fixes, new drivers, bugs and other features.

[[Installing_source]]
Installing from source
----------------------

These are the essential steps for compiling and installing this software
from distribution archives (usually "release tarballs") which include a
pre-built copy of the `configure` script and some other generated source
files.

To build NUT from a Git checkout you may need some additional tools
(referenced just a bit below) and run `./autogen.sh` to generate the
needed files. For common developer iterations, porting to new platforms,
or in-place testing, running the `./ci_build.sh` script can be helpful.

The NUT linkdoc:packager-guide[Packager Guide], which presents the best
practices for installing and integrating NUT, is also a good reading.

The link:config-prereqs.txt[Prerequisites for building NUT on different OSes]
document suggests prerequisite packages with tools and dependencies
available and needed to build and test as much as possible of NUT on
numerous platforms, written from perspective of CI testing (if you
are interested in getting updated drivers for a particular device,
you might select a sub-set of those suggestions).

[NOTE]
.Keep in mind that...
================================================================================

- the paths shown below are the default values you get by just calling
  configure by itself.  If you have used --prefix or similar, things will be
  different.  Also, if you didn't install this program from source yourself,
  the paths will probably have a number of differences.

- by default, your system probably won't find the man pages, since they
  install to /usr/local/ups/man.  You can fix this by editing your MANPATH,
  or just do this:

	man -M /usr/local/ups/man <man page>

- if your favorite system offers up to date binary packages, you should
  always prefer these over a source installation (unless there are known
  deficiencies in the package or one is too obsolete). Along with the known
  advantages of such systems for installation, upgrade and removal, there
  are many integration issues that have been addressed.

================================================================================


Prepare your system
~~~~~~~~~~~~~~~~~~~~

System User creation
^^^^^^^^^^^^^^^^^^^^

Create at least one system user and a group for running this software.
You might call them "ups" and "nut".  The exact names aren't important as
long as you are consistent.

The process for doing this varies from one system to the next, and
explaining how to add users is beyond the scope of this document.

For the purposes of this document, the user name and group name
will be 'ups' and 'nut' respectively.

Be sure the new user is a member of the new group!  If you forget to
do this, you will have problems later on when you try to start upsd.


Build and install
~~~~~~~~~~~~~~~~~

[[Configuration]]
Configuration
^^^^^^^^^^^^^

Configure the source tree for your system.  Add the '--with-user' and
'--with-group' switch to set the user name and group that you created
above.

	./configure --with-user=ups --with-group=nut

If you need any other switches for configure, add them here.  For example:

* to build and install USB drivers, add '--with-usb' (note that you
  need to install libusb development package or files).

* to build and install SNMP drivers, add '--with-snmp' (note that
  you need to install libsnmp development package or files).

* to build and install CGI scripts, add '--with-cgi'.

See <<Configure_options,Configure options>> from the User Manual,
docs/configure.txt or './configure --help' for all the available
options.

If you alter paths with additional switches, be sure to use those
new paths while reading the rest of the steps.

Reference: <<Configure_options,Configure options>> from the
User Manual.


Build the programs
^^^^^^^^^^^^^^^^^^

	make

This will build the NUT client and server programs and the
selected drivers. It will also build any other features that were
selected during <<Configuration,configuration>> step above.


Installation
^^^^^^^^^^^^

[NOTE]
=====================================================================

you should now gain privileges for installing software if necessary:

	su

=====================================================================

Install the files to a system level directory:

	make install

This will install the compiled programs and man pages, as well as
some data files required by NUT. Any optional features selected
during configuration will also be installed.

This will also install sample versions of the NUT configuration
files. Sample files are installed with names like ups.conf.sample
so they will not overwrite any existing real config files you may
have created.

If you are packaging this software, then you will probably want to
use the DESTDIR variable to redirect the build into another place,
i.e.:

	make DESTDIR=/tmp/package install
	make DESTDIR=/tmp/package install-conf

[[StatePath]]
State path creation
^^^^^^^^^^^^^^^^^^^

Create the state path directory for the driver(s) and server to use
for storing UPS status data and other auxiliary files, and make it
group-writable by the group of the system user you created.

	mkdir -p /var/state/ups
	chmod 0770 /var/state/ups
	chown root:nut /var/state/ups

[[Ownership]]
Ownership and permissions
^^^^^^^^^^^^^^^^^^^^^^^^^

Set ownership data and permissions on your serial or USB ports
that go to your UPS hardware.  Be sure to limit access to just
the user you created earlier.

These examples assume the second serial port (ttyS1) on a typical
Slackware system.  On FreeBSD, that would be cuaa1.  Serial ports
vary greatly, so yours may be called something else.

	chmod 0660 /dev/ttyS1
	chown root:nut /dev/ttyS1

////////////////////////////////////////////////////////////////////////////////
FIXME: TBR
////////////////////////////////////////////////////////////////////////////////

The setup for USB ports is slightly more complicated. Device files
for USB devices, such as /proc/bus/usb/002/001, are usually
created "on the fly" when a device is plugged in, and disappear
when the device is disconnected.  Moreover, the names of these
device files can change randomly. To set up the correct
permissions for the USB device, you may need to set up (operating
system dependent) hotplugging scripts.  Sample scripts and
information are provided in the scripts/hotplug and
scripts/udev directories. For most users, the hotplugging scripts
will be installed automatically by "make install".

(If you want to try if a driver works without setting up
hotplugging, you can add the "-u root" option to upsd, upsmon, and
drivers; this should allow you to follow the below
instructions. However, don't forget to set up the correct
permissions later!).

NOTE: if you are using something like udev or devd, make sure
these permissions stay set across a reboot.  If they revert to the
old values, your drivers may fail to start.


You are now ready to configure NUT, and start testing and using it.

You can jump directly to the <<Configuration_notes,NUT configuration>>.


[[Installing_packages]]
Installing from packages
------------------------

This chapter describes the specific installation steps when using
binary packages that exist on various major systems.

[[Debian]]
Debian, Ubuntu and other derivatives
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NOTE: NUT is packaged and well maintained in these systems.
The official Debian packager is part of the NUT Team.

Using your preferred method (apt-get, aptitude, Synaptic, ...), install
the 'nut' package, and optionally the following:

- 'nut-cgi', if you need the CGI (HTML) option,
- 'nut-snmp', if you need the snmp-ups driver,
- 'nut-xml', for the netxml-ups driver,
- 'nut-powerman-pdu', to control the PowerMan daemon (PDU management)
- 'nut-dev', if you need the development files.

////////////////////////////////////////////////////////////////////////////////
- nut-client
////////////////////////////////////////////////////////////////////////////////

Configuration files are located in /etc/nut.
linkman:nut.conf[5] must be edited to be able to invoke /etc/init.d/nut

NOTE: Ubuntu users can access the APT URL installation by clicking
on link:apt://nut[this link].


[[Mandriva]]
Mandriva
~~~~~~~~

NOTE: NUT is packaged and well maintained in these systems.
The official Mandriva packager is part of the NUT Team.

Using your preferred method (urpmi, RPMdrake, ...), install one of the
two below packages:

- 'nut-server' if you have a 'standalone' or 'netserver' installation,
- 'nut' if you have a 'netclient' installation.

Optionally, you can also install the following:

- 'nut-cgi', if you need the CGI (HTML) option,
- 'nut-devel', if you need the development files.


[[SUSE]]
SUSE / openSUSE
~~~~~~~~~~~~~~~

NOTE: NUT is packaged and well maintained in these systems.
The official SUSE packager is part of the NUT Team.

Install the 'nut-classic' package, and optionally the following:

- 'nut-drivers-net', if you need the snmp-ups or the netxml-ups drivers,
- 'nut-cgi', if you need the CGI (HTML) option,
- 'nut-devel', if you need the development files,

NOTE: SUSE and openSUSE users can use the
link:http://software.opensuse.org/search?baseproject=ALL&p=1&q=nut[one-click install method]
to install NUT.


[[RedHat]]
Red Hat, Fedora and CentOS
~~~~~~~~~~~~~~~~~~~~~~~~~~

NOTE: NUT is packaged and well maintained in these systems.
The official Red Hat packager is part of the NUT Team.

Using your preferred method (yum, Add/Remove Software, ...), install
one of the two below packages:

- 'nut' if you have a 'standalone' or 'netserver' installation,
- 'nut-client' if you have a 'netclient' installation.

Optionally, you can also install the following:

- 'nut-cgi', if you need the CGI (HTML) option,
- 'nut-xml', if you need the netxml-ups driver,
- 'nut-devel', if you need the development files.


[[FreeBSD]]
FreeBSD
~~~~~~~

You can either install NUT as a binary package or as a port.

Binary package
^^^^^^^^^^^^^^

To install NUT as a package execute:

	# pkg install nut

Port
^^^^

The port is located under +sysutils/nut+.
Use +make config+ to select configuration options, e.g. to build the
optional CGI scripts.
To install it, use:

	# make install clean

USB UPS on FreeBSD
^^^^^^^^^^^^^^^^^^

For USB UPS devices the NUT package/port installs devd rules in
+/usr/local/etc/devd/nut-usb.conf+ to set USB device permissions.
 'devd' needs to be restarted  for these rules to apply:

	# service devd restart

(Re-)connect the device after restarting 'devd' and check that the USB
device has the proper permissions. Check the last entries of the system
message buffer. You should find an entry like:

	# dmesg | tail
	[...]
	ugen0.2: <INNO TECH USB to Serial> at usbus0

The device file must be owned by group +uucp+ and must be group
read-/writable. In the example from above this would be

	# ls -Ll /dev/ugen0.2
	crw-rw----  1 root  uucp  0xa5 Mar 12 10:33 /dev/ugen0.2

If the permissions are not correct, verify that your device is registered in
+/usr/local/etc/devd/nut-usb.conf+. The vendor and product id can be found
using:

	# usbconfig -u 0 -a 2 dump_device_desc

where +-u+ specifies the USB bus number and +-a+ specifies the USB device
index.


[[Windows]]
Windows
~~~~~~~

Windows binary package
^^^^^^^^^^^^^^^^^^^^^^

[NOTE]
======
NUT binary package built for Windows platform was last issued for
a much older codebase (using NUT v2.6.5 as a baseline). While the current
state of the codebase you are looking at aims to refresh the effort of
delivering NUT on Windows, the aim at the moment is to help developers
build and modernize it after a decade of blissful slumber, and packages
are not being regularly produced yet. Functionality of such builds varies
a lot depending on build environment used. This effort is generally
tracked at https://github.com/orgs/networkupstools/projects/2/views/1
and help would be welcome!

It should currently be possible to build the codebase in native Windows
with MSYS2/MinGW and cross-building from Linux with mingw (preferably
in a Debian/Ubuntu container). Refer to
link:config-prereqs.txt[Prerequisites for building NUT on different OSes]
and link:scripts/Windows/README[scripts/Windows/README file] for respective
build environment preparation instructions.

Note that to use NUT for Windows, non-system dependency DLL files must
be located in same directory as each EXE file that uses them. This can be
accomplished for FOSS libraries (copying them from the build environment)
by calling `make install-win-bundle DESTDIR=/some/valid/location` easily.

Archives with binaries built by recent iterations of continuous integration
jobs should be available for exploration on the respective CI platforms.
======

*Information below may be currently obsolete, but the NUT project wishes
it to become actual and factual again :)*

NUT binary package built for Windows platform comes in a `.msi` file.

If you are using Windows 95, 98 or Me, you should install
link:http://www.microsoft.com/downloads/en/details.aspx?familyid=cebbacd8-c094-4255-b702-de3bb768148f&displaylang=en[Windows Installer 2.0]
from Microsoft site.

If you are using Windows 2000 or NT 4.0, you can
link:http://www.microsoft.com/downloads/en/details.aspx?FamilyID=4b6140f9-2d36-4977-8fa1-6f8a0f5dca8f&DisplayLang=en[download it here].

Newer Windows releases should include the Windows Installer natively.

Run `NUT-Installer.msi` and follow the wizard indications.

If you plan to use an UPS which is locally connected to an USB port,
you have to install
link:https://sourceforge.net/projects/libusb-win32/files/[libUSB-win32]
on your system. Then you must install your device via libusb's "Inf Wizard".

NOTE: If you intend to build from source, relevant sources may be available at
https://github.com/mcuee/libusb-win32 and keep in mind that it is a variant of
libusb-0.1. Current NUT supports libusb-1.0 as well, and that project should
have Windows support out of the box (but it was not explored for NUT yet).

If you have selected default directory, all configuration files are located in
`C:\Program Files\NUT\ups\etc`

Building for Windows
^^^^^^^^^^^^^^^^^^^^

For suggestions about setting up the NUT build environment variants
for Windows, please see link:docs/config-prereqs.txt and/or
link:scripts/Windows/README files. Note this is rather experimental
at this point.


Runtime configuration
~~~~~~~~~~~~~~~~~~~~~

You are now ready to configure NUT, and start testing and using it.

You can jump directly to the
<<Configuration_notes,NUT configuration>>.
