cbt: Conservative Build Tool
============================
cbt is a simple bash script-based source code build tool primarily developed to
construct customized Linux systems from source code.

It used to be my own automated build solution for deploying customized systems
based on [Linux from Scratch (LFS)](http://linuxfromscratch.org) between
2001-2009, before I switched to using [Nix](https://nixos.org/nix) and
[NixOS](https://nixos.org) as my preferred deployment automation solutions.

In addition to LFS, cbt can also be used to automate the deployment of packages
from source code and other kinds of configuration aspects on conventional Linux
distributions.

Why is it called CBT? It is a very simple tool that is implemented for one kind
of job only: building systems from scratch. Package deployment is a much more
complicated problem than just doing that.

For example, upgrading already deployed systems is a much harder problem than
deploying system from scratch -- when upgrading a package you also need to take
its dependencies into account and make sure that they do not break.

Moreover, ensuring reproducible builds is also complicated and not something the
tool helps you with. There are much better tools out there that take care of
these additional deployment tasks.

CBT does not have the intention to change to address these additional issues and
become a more advanced tool. That is why call it is called conservative -- it is
the inertia to change.

Although this tool has mostly lost its value because much better and more
powerful solutions exist, it still remains useful to me for retro-computing
purposes -- for example, to construct old Linux distributions from source code
(with old versions of commonly used packages) running on old machines with much
fewer system resources compared to modern machines.

Prerequisites
=============
* [bash](https://www.gnu.org/software/bash). I have used bash 2.05 as the oldest
  version
* GNU variants of various shell commands. You need GNU Find, GNU Grep, GNU
  Coreutils (or GNU fileutils, shell-utils, text-utils on older Linux
  distributions)
* `getopt` for command-line option parsing. This tool is part of
  [util-linux](https://github.com/util-linux/util-linux).
* [dialog](https://invisible-mirror.net/archives/dialog) for generating
  text-based user interfaces (TUIs)
* For building packages integrating with the host system's package manager:
  [checkinstall](https://checkinstall.izto.org)
* A package manager that checkinstall supports: Slackware, RPM or dpkg

Installation
============
Installing the tools can be done by running:

```bash
make install
```

You can set the `PREFIX=/usr` parameter to install it in another prefix, such
as `/usr`.

Development
===========
In addition to installing the tools on the host system, it is also possible to
directly use the tools from a development checkout (e.g. `$HOME/Dev/cbt`) which
is useful for development.

You must set the following environment variables so that shared functionality
can be found:

```bash
export CBT_DATADIR=$HOME/Dev/cbt
export CBT_BINDIR=$HOME/Dev/cbt/bin
```

and adding the tools to your PATH:

```bash
export PATH=$PATH:$HOME/Dev/cbt/bin
```

Concepts
========
cbt is based on a few simple concepts.

With cbt, you define *sequences* of *scripts*. A selection of scripts in a
sequence can be executed in linear order.

In addition, cbt takes care of the following aspects while executing a sequence
of scripts:

* It automatically logs the output of the scripts in a centralized logging
  directory
* It allows you to set break points so that the execution of a sequence can be
  interrupted and resumed at a later point in time
* It memorizes which scripts have already been executed. Executing a sequence
  for a second time will skip previously executed scripts
* It allows users to select which scripts in a sequence should be executed or
  not
* Script can define dependencies on external files. cbt can automatically query
  them so that it is know what external files are required to deploy a system.

Scripts
-------
A cbt script is a bash shell script file with the following structure:

```bash
#!/bin/bash -e

name=hello-world
group=Scripts/Test
description="Printing a hello world message"
executeFunction=helloWorldFunction

helloWorldFunction()
{
    mkdir -p $TMPDIR/hello-world
    echo "Hello world!" > $TMPDIR/hello-world/hello-world.txt
}
```

The above example cbt script (`hello-world`) defines the following attributes:
* A script has a name that needs to be specified by using the `name` attribute.
  This attribute is used for a variety of purposes, for example, in the filename
  of the log file.
* `group` is an attribute that defines how the script is categorized. Log files
  are categorized in the same directory structure
* `description` is an attribute that gives a short description of the purpose
  of the script
* `executeFunction` is an attribute that refers to a bash function that needs to
  be executed. If this attribute is undefined, it will default to: `execute`
* `helloWorldFunction()` is the function that the `executionFunction` attribute
  refers to. When executing a sequence, this function captures the procedure
  that gets executed.

Functions typically do not have to be redefined for each script. It is also
possible to reuse functions.

For example, the cbt package includes a shell function named `deployPackage`
that is capable of executing a build process and deploying a package by using
the host system's package manager by using `checkinstall`. Each time that you
want to deploy a package, this function (or abstraction functions built on top
of it) are re-used.

The `cbt-run-script` tool can be used to execute a script. For example, the
`hello-world` script can be executed as follows:

```bash
$ cbt-run-script scripts/Scripts/Test/hello-world
```

The result of executing `helloWorldFunction` is a file named `hello-world.txt`
that resides in the `/tmp/hello-world` folder.

The output of the script can be found in the following log file:
`/var/log/cbt/Scripts/Test/hello-world.log`

In addition to executing a script, it is also possible to view the properties
of a script by running:

```bash
$ cbt-show-script scripts/Scripts/Test/hello-world
```

Sequence
--------
A cbt sequence is a bash shell script with the following structure:

```bash
#!/bin/bash -e

optional="true"

scripts="\
Scripts/Test/hello-world \
Scripts/Test/bye-world \
"
```

The above cbt sequence (`testsequence`) defines two properties:
* `optional` indicates whether the scripts inside the sequence need to be
  optionally executed. If this property is `false`, then all scripts are
  considered mandatory and are executed by default unless they are disabled by
  the user.

  If `true`, then only the scripts that have been enabled by the user are
  executed. The default value is `false`.

  Sequences that deploy low-level operating system parts are typically
  mandatory. Sequences that deploy end-user application software are often
  optional.
* The `scripts` attribute contains a whitespace separated list of paths to
  scripts that need to be executed. In the example, it contains two scripts.
  The first script refers to the example given in the previous section.

Selecting the scripts to be executed in a sequence can be done by using the
`cbt-cfg-seq` tool.

To configure scripts to be exectued in the above example sequence
(`testsequence`), we can run:

```bash
$ cbt-cfg-seq sequences/testsequence
```

The above tool opens a TUI allowing a user to select the scripts to be executed
in the provided sequence.

Using the configurator mostly makes sense for optional sequences. For mandatory
sequences, all scripts have been enabled by default. However, the tool can still
be useful for mandatory sequences to re-enable a previously executed step.

After configuring a sequence, you can execute the selected scripts in the
sequence with the following command:

```bash
$ cbt-run-seq sequences/testsequence
```

While the `cbt-run-seq` command is executing you can see an overview of the
scripts that have been executed in the first terminal, and the output of the
current script in execution in the second terminal. You can switch to the first
terminal with the Alt+F1 key combination and to second with Alt+F2.

It is also possible to browse the scripts in a sequence and view their
properties, by running:

```bash
$ cbt-show-seq sequences/testsequence
```

Breakpoints
-----------
Sequences may take a long time to complete. If desired, it is also possible to
stop them somewhere in the middle by setting a break point and resuming the
execution at a later point in time.

We can configure a break point after the current script in execution in the
sequence by running:

```bash
$ cbt-break-next sequences/testsequence
```

We can also select a script in a sequence to put the breakpoint after, by
running:

```bash
$ cbt-break-seq sequences/testsequence
```

The above command opens a TUI allowing you to select the script in a sequence
where a breakpoint needs to be put after.

We can clear the break point with the following command:

```bash
$ cbt-clear-brk sequences/testsequence
```

File dependencies
=================
In addition to defining scripts that execute something, scripts may also need
to work with external files to accomplish something, such as unpacking an
archive with source code, building it and installing it.

When file dependencies are needed, it is typically a common habit to specify
paths relative to a common source directory. You typically want to store this
directory in a common settings file, such as `settings/testsequence`:

```bash
#!/bin/bash -e

sourcesDir=/mnt/source
```

In the following example script (`copy-file`), we have defined an external file
dependency that we copy to the system wide binaries folder:

```bash
#!/bin/bash -e

source $cbtBaseDir/settings/testsequence

name=copy-file
group=Scripts/Test
description="Copies a file to the temp directory"
executeFunction=copyFileFunction
dependencyVariables="files"
files=("sources/myexecutable")

copyFileFunction()
{
    cp $sourcesDir/${files[0]} $TMPDIR
}
```

By default, the `files` variable is used to specify which files are external
file dependencies. This variable is allowed to refer to an individual file
(as a string) or multiple files (as an array of strings).

It is also possible to change the file dependency variables by modifying the
`dependencyVariables` variable. This variable refers to a white space separated
list of variable names containing file dependencies.

The above script also includes our previously defined settings file to use the
common `$sourcesDir` setting.

With the `cbt-script-deps` tool it is possible to query a script's file 
dependencies:

```bash
$ cbt-script-deps scripts/Scripts/Test/copyFile
sources/myexecutable
```

It is also possible to query file dependencies of all scripts in a sequence
with the following the `cbt-seq-deps` command:

```bash
$ cbt-seq-deps sequences/testsequence
```

Functions
=========
As explained earlier, cbt scripts execute bash functions. There are a number of
reusable functions included with the cbt package to make it easier to build
and install software.

Functions can be included from a cbt script as follows:

```bash
source $cbtFunctionsDir/<function>
```

The `$cbtFunctionsDir` variable reference refers to the directory in which
reusable functions can be found. The next sub sections describe the functions
bundled with the cbt package.

deployPackage
-------------
`deployPackage` is a function that facilitates source package deployments from
a low-level perspective. It executes commands that are captured in two
environment variables:

* `buildCommand` specifies the shell instructions to build the package from
  source code. Build instructions are typically executed in a (somewhat)
  protected environment -- they run as an unprivileged user in a directory that
  is only accessible by the build user.
* `installCommand` specifies the instructions to install the package and runs
  with super-user privileges. These instructions are executed in combination
  with `checkinstall`. Under the hood, `checkinstall` uses `installwatch` to
  record file modifications and automatically creates and deploys a package by
  using the host system's package manager.

For each package build, the `deployPackage` function automatically creates a
designated temp directory in `$TMPDIR/cbt/$name`. If a build successfully
completes, this temp directory is automatically removed. In case of a failure, it
is retained so that errors can be diagnosed. When a temp directory is kept, it
is recommended to remove it before running scripts in a sequence again.

The build command accepts the following parameters:

* `buildAsRoot` specifies whether to build the package as root user. In general,
  you do not want this as it less secure (as a result, the default setting is
  `false`). In some exceptional cases, such as the Linux kernel source code
  (that needs to be retained after building it), you may want to set it to
  `true`.
* `builderUser` specifies the user name of the unpriviliged build user
* `builderGroup` specifies the user group of the unprivileged build user

The install command accepts the following parameters:

* `showLongDescription` is a function that generates a longer description for
  the package describing it in more detail. This long description becomes part
  of the package.
* `packageType`, specifies which type of package `checkinstall` needs to create.
  Checkinstall supports `slackware`, `rpm` or `debian`
* `version` specifies the version number of the package. If no version was
  specified, it defaults to: `noversion`
* `arch` specifies the package's architecture. If no value was specified it
  defaults to the output of `arch -m`
* `license` specifies the package's license. If none if specified it defaults
  to: `restricted`
* `release` indicates the release version. Defaults to `1`
* `strip` indicates whether to strip the executables (default is: `yes`)
* `stripSo` indicates whether to strip the shared libraries (default is: `yes`)
* `gzman` indicates whether to compress man and info pages with gzip (default
  is: `no`). This feature is somewhat broken in checkinstall -- if enabled, both
  compressed and uncompressed versions of the same file are stored concurrently.
* `pakDir` provides the location where the generated packages are stored
  (defaults to: `/var/cache/cbt`)

* `noCheckInstall` can be used to directly execute the install command without
  using `checkinstall`. This feature is only needed in exceptional cases, for
  example to bootstrap `checkinstall`
* `noRemoveBuildDir` can be used to retain the temp directory after the
  deployment process completes. This feature is only needed in exceptional cases
  for example, in the bootstrap phase of a distribution in which glibc calls
  cannot be intercepted by `checkinstall`. You typically want to install the
  package a second time (after completing the bootstrap) so that library calls
  can be properly intercepted.

The following file shows an example of how the deploy function can be used:

```bash
#!/bin/bash -e

source $cbtFunctionsDir/deployPackage
source $cbtBaseDir/settings/testsequence

name=hello
version=2.1.1
group=Packages/Test
description="GNU Hello"
files=("$name-$version.tar.gz")

showLongDescription()
{
    cat << "EOF"
The GNU Hello program produces a familiar, friendly greeting. GNU Hello
processes its arguments list to modify its behavior, supports greetings in many
languages, and so on.

The primary purpose of GNU Hello is to demonstrate how to write other programs
to do thse things; it serves as a model for GNU coding standards and GNU
maintainer practices.
EOF
}

buildCommand="tar xfvz $sourcesDir/${files[0]} && cd $name-$version && ./configure && make"
installCommand="cd $name-$version && make install"
executeFunction=deployPackage
```

The above script file (`hello`) specifies how to build the
[GNU Hello](https://www.gnu.org/software/hello) project version `2.1.1` from
source code. The `showLongDescription` function generates a long description
that describes the package in more detail. The `buildCommand` attribute
specifies the build instructions and the `installCommand` the installation
instructions.

deployPhases
------------
Writing build and installation instructions inside environment variables as
strings is somewhat inconvenient. Moreover, many package build processes follow
conventions consisting of similar kinds of steps that need to be repeated over
and over again.

The `deployPhases` function provides an abstraction on top of the previously
shown `deployPackage` function, allowing a user to specify the *phases* of which
a package deployment process consists. These phases can be implemented as bash
functions. Writing package build processes this way is much more convenient.

This function configures the `buildCommand` and `installCommand` attributes to
invoke a command-line tool named: `cbt-run-phases` to carry out the execution of
the phases.

In addition to the parameters of `deployPackage`, this function accepts the
following parameters:

* `buildPhases` refers to a white space separated list of phases of which the
  build process consists
* `installPhases` refers to a white space separated list of phases of which the
  installation process consists

Each phase will execute three bash functions:
* The `pre<phaseName>` function gets executed before a phase starts
* The `<phaseName>Phase` function contains the implementation of the phase
* The `post<phaseName>` function gets executed after a phase starts

The following example script demonstrates how our previous GNU Hello example can
be written in a more readable way by using the `deployPhases` function:

```bash
#!/bin/bash -e

source $cbtFunctionsDir/deployPhases
source $cbtBaseDir/settings/testsequence

name=hello
version=2.1.1
group=Tools/Development
description="GNU Hello"
files=("$name-$version.tar.gz")

showLongDescription()
{
    cat << "EOF"
The GNU Hello program produces a familiar, friendly greeting. GNU Hello
processes its arguments list to modify its behavior, supports greetings in many
languages, and so on.

The primary purpose of GNU Hello is to demonstrate how to write other programs
to do thse things; it serves as a model for GNU coding standards and GNU
maintainer practices.
EOF
}

unpackPhase()
{
    tar xfvz $sourcesDir/${files[0]}
}

openWorkDirPhase()
{
    cd $name-$version
}

buildPhase()
{
    ./configure
    make
}

installPhase()
{
    make install
}

buildPhases="unpack openWorkDir build"
installPhases="openWorkDir install"
```

In the above example we have changed the following aspects:
* The `buildPhases` variable refers to the functions that need to be executed in
  the build phase. As shown in the previous section, build commands run as an
  unprivileged user by default.
* The `installPhases` variable refers to the functions that need to be executed
  in the install phase
* Each phase has been implemented by a function

deploySourcePackage
-------------------
`deploySourcePackage` extends the `deployPhases` function with commonly used
phases and implementations of some of these phases that are regularly used to
build packages from source code.

It defines the following phases:

* `buildPhases="unpack openWorkDir patch build"`
* `installPhases="openWorkDir install"`

The following phases provide a default implementation:

* `unpack` unpacks all files specified in the `srcs` and `src` variables.
  The unpack command is determined from the file name extension by unpack modules
  residing in the `unpack-plugins` folder. Relative paths are relative to the
  `sourcesDir` directory. Furthermore, dependencies in `src` and `srcs` are also
  considered to be file dependencies of the script
* `openWorkDir` opens the work directory. By default, it checks for the presence
  of a single folder in the temp directory. If multiple directories exist, the
  work dir can be specified with the `workDir` environment variable.
* `patch` automatically applies all patches specified in the `patches` variable.
  The `defaultPatchLevel` variable can be used to specify the patch level. If no
  patch level is specified it defaults to `1`. The patches are also considered to
  be file dependencies.

The following phases need to be implemented for each package:

* `build` executes the instructions to build the package from source code
* `install` executes the instructions to install the package

The following example shows how the previous GNU Hello example can be simplified
by using the `deploySourcePackage` function:

```bash
#!/bin/bash -e

source $cbtFunctionsDir/deploySourcePackage
source $cbtBaseDir/settings/testsequence

name=hello
version=2.1.1
group=Tools/Development
description="GNU Hello"
src="$name-$version.tar.gz"

showLongDescription()
{
    cat << "EOF"
The GNU Hello program produces a familiar, friendly greeting. GNU Hello
processes its arguments list to modify its behavior, supports greetings in many
languages, and so on.

The primary purpose of GNU Hello is to demonstrate how to write other programs
to do thse things; it serves as a model for GNU coding standards and GNU
maintainer practices.
EOF
}

buildPhase()
{
    ./configure
    make
}

installPhase()
{
    make install
}
```

In the above example, we no longer have to specify phases because the common
phases cover the required build procedure well enough. Moreover, the unpack and
opening the work is transparently handled for us.

deployTrivialPackage
--------------------
`deployTrivialPackage` extends the `deployPhases` function with only an
`install` phase. Compared to the `deploySourcePackage`, this function is much
simpler and typically useful to deploy configuration files and scripts that
do not require any building.

The following example shows how this function can be used to deploy a
single-executable package consisting of the shell script: `bin/again`.

The executable is copied from the `test-script/` sub directory of the
configuration directory tree:

```bash
#!/bin/bash -e

source $cbtFunctionsDir/deployTrivialPackage

name=again-script
group=Packages/Test
description="Simple executable that says: again"

installPhase()
{
    install -m755 -d /tmp/bin
    install -m755 $cbtBaseDir/test-script/again /tmp/bin
}
```

deployDesktopItem
-----------------
`deployDesktopItem`'s purpose is to deploy a freedesktop.org compatible .desktop
file to make an application visible in the program launcher menus of a variety
of desktop environments, including KDE and GNOME. This function is typically
useful to augment existing desktop application packages from the host system
with menu links if they are absent.

This function is built on top of the `deployPhases` function.

In addition to the `deployPhases` parameters, it accepts the following
parameters:

* `desktopFolders` is a white space separated list of paths in which desktop
  files are supposed to be stored
* `desktopFileName` specifies the name of the .desktop file. If it is left
  unspecified, it takes the value from the `name` variable
* `desktopName` is the name of the application in the menu
* `exec` refers to the executable that needs to be launched
* `comment` provides a more detailed description of the menu item
* `icon` provides the path to an icon to be displayed. This field is optional.
* `terminal` is it set to 1, a terminal window is opened. By default it is `0`
* `terminalOptions` provides the terminal window parameters
* `path` provides the current working directory that needs to be opened before
  running the executable. This field is optional.
* `mimeType` refers to a semi-colon seperated set of MIME types that the
  application accepts. This field is optional

deployDesktopSourcePackage
--------------------------
This function combines the functionality of the `deploySourcePackage` and
`deployDesktopItem` functions. It is a useful function abstraction to deploy
desktop application packages from source code that do not include any desktop
links.

It accepts the combination of the parameters of both functions.

Unpack plugins
==============
As mentioned in the previous section, the `deploySourcePackage` function
includes an `unpack` phase that generically unpacks source archives. It does so
by iterating over all available plugins inside the `$CBT_UNPACK_PLUGINS`
directory (which defaults to: `/usr/local/share/cbt/unpack-plugins`).

The anatomy of these plugins is simple -- a plugin is a bash script that
checks the provided filename and decides whether it can do something with it
(e.g. it may look at the filename extension). If so, it will perform the unpack
operation and sets the `hasUnpacked` environment variable to `1`, causing the
unpack process for the file to stop.

If the unpack plugin does not understand a file, it will do nothing and leave
the `hasUnpacked` environment variable unset causing another plugin to pick it
up. If no plugin detects the file type, an error is returned.

By default, the `cbt` toolset only contains one unpack plugin: `tar`, that
detects and unpacks uncompressed or compressed tarballs. The `tar` plugin is
included, as it is the most common archive format on GNU/Linux systems.

Other archive formats can be supported by installing a plugin (into
`$CBT_UNPACK_PLUGINS`) alongside the package that provides the archiver tool.
For example, to support `zip` archives the `unzip` package installs an `unzip`
plugin into the plugin folder

Uncompress plugins
==================
Another phase that the `deploySourcePackage` function implements is the the
`patch` phase in which patch files are automatically applied to the source code
tree residing in the working directory.

Patch files may be compressed. To automatically uncompress them, the
`deploySourcePackage` function consults all uncompress plugins residing in the
`$CBT_UNCOMPRESS_PLUGINS` directory (which defaults to:
`/usr/local/share/cbt/uncompress-plugins`).

Uncompress plugins are bash scripts that examine the given patch file and if the
compression technique is recognized, it uncompresses the file to the standard
output and sets the `hasUncompressed` environment variable to `1` causing the
process to stop.

If no compression method was recognized, the file is redirected the standard
output without any modification.

By default the `cbt` toolset only includes plugins for the `gzip` and `bzip2`
formats, as they are commonly used on GNU/Linux systems.

Other compression formats can be supported by installing plugins into the
`$CBT_UNCOMPRESS_PLUGINS` alongside the package that provides the uncompressor
tools.

Global configuration settings
=============================
To be able to conveniently use the cbt toolset, some global settings need to be
provided. cbt uses the `CBT_GLOBAL_CONFIG` environment variable to determine
the location of the global configuration file (that defaults to:
`/etc/cbt/cbt`):

```bash
# deployPackage settings
builderUser=lfs
builderGroup=lfs
packageType=slackware
```

In the above global configuration file, we provide common settings that apply to
all scripts. Although you can also provide these settings on script-level, it is
typically more convenient to provide these globally because they are often the
same for any kind of script

For example, when invoking `deployPackage` (or abstractions built on top of
it) we always want to perform the builds by the same unprivileged user (`lfs`).

For the deployPackage you also need to create the corresponding unprivileged
`lfs` user account:

```bash
groupadd lfs
useradd -m -g lfs lfs
```

Test configuration
==================
There is a test configuration in the `test-config` sub directory, which
contains an optional sequence with some test cases, such as the example scripts
shown in this `README.md` file.

You can open the directory as follows:

```bash
$ cd test-config
```

We can enable scripts in the test sequence as follows:

```bash
$ cbt-cfg-seq sequences/testsequence
```

And execute the sequence as follows:

```bash
$ cbt-run-seq sequences/testsequence
```

For the scripts that build GNU Hello, you need `checkinstall` to be present on
your machine. If it is not installed already, you can bootstrap it by enabling
the `checkinstall` script in the `Tools/Additional` group.

License
=======
This package is available under the terms and conditions of the
[2-Clause BSD License](./COPYING)
