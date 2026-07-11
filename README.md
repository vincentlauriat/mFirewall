# mFirewall

[简体中文](README_zh-Hans.md) | [正體中文](README_zh-Hant.md)

mFirewall is a free, open-source macOS firewall that monitors and blocks unauthorized outgoing network connections, protecting your privacy and your Mac. Unlike macOS's built-in firewall, which only filters incoming traffic, mFirewall flags suspicious or unexpected outbound connections from apps and processes.

**Documentation:** \
Full installation, usage, and FAQ can be found in the [user guide](docs/USAGE.md), also published at <https://lauriat.fr/outils/mfirewall>.

## Features

- **Smart alerts** — immediate notification when a process attempts a new, unauthorized outgoing connection
- **Flexible rules** — allow or block by process, with configurable scope and duration (always, once, per-process, custom)
- **Rule management** — dedicated window to view, add, edit, import/export, and delete rules
- **Operating modes** — passive (silent logging), block, and no-icon modes
- **Profiles** — separate rule sets and preferences for different contexts
- **Code-signing insight** — inspect signing information for the process behind any connection
- **Allow/block lists** — support for local files or remote URLs
- **Network Monitor integration** — hook into Netiquette for deeper traffic visibility

## Build

See [CLAUDE.md](CLAUDE.md) for build instructions, architecture notes, and how to run the test suite.

## Source & Issues

<https://github.com/vincentlauriat/mFirewall>

## Origin & License

mFirewall is a fork/rebrand of [LuLu](https://github.com/objective-see/LuLu), originally created by Patrick Wardle and [Objective-See](https://objective-see.org). All credit for the original design and implementation goes to the Objective-See project. Like the upstream project, mFirewall is licensed under the [GNU General Public License v3](LICENSE.md).
