# mFirewall — User Guide

Nearly every application makes network connections. So does malware. mFirewall is a free, open-source firewall that blocks unknown outgoing connections, protecting your privacy and your Mac.

Unlike macOS's built-in firewall, which only filters *incoming* traffic, mFirewall monitors and blocks unauthorized *outgoing* connections — the kind malware relies on to reach a command & control server or exfiltrate data.

Online version of this guide: <https://lauriat.fr/outils/mfirewall>

## Installation

1. Double-click `mFirewall.dmg` and, in the window that appears, drag `mFirewall.app` into the `/Applications` folder.
2. After copying `mFirewall.app` to `/Applications`, launch the copy *from* `/Applications` to continue installation (macOS requires apps with System Extensions to run from `/Applications`).
3. Approve the system extension (four steps):
   - Click "Open System Settings" when prompted.
   - Enable mFirewall's extension via the toggle in System Settings.
   - Authenticate to approve the extension.
   - Click "Allow" to finish approving mFirewall.
4. On first run, it's recommended to leave the default options selected — these allow Apple and already-installed programs to keep accessing the network without alerting you, so you're not flooded with alerts for trusted software.

## Alerts

mFirewall shows an alert whenever a process attempts a new, unauthorized outgoing connection. Each alert shows the process attempting the connection and its destination, with options to block or allow it.

- **Hover for detail** — mousing over the program's name or the connection reveals either the program's full path or the full URL/host it's attempting to reach.
- **Code-signing info** — inspect the signing information of the process to help decide whether it's trustworthy.
- **Process hierarchy** — see the parent process chain behind the connection attempt.
- **VirusTotal integration** — VirusTotal analyzes files and URLs for malware by scanning them with multiple antivirus engines and security tools; click the VirusTotal button in an alert to check the responsible binary's hash. This is the only case where mFirewall makes an outbound request beyond the app itself — see the FAQ below.
- **Details and Options** — click the disclosure button to expand the alert and reveal advanced options:
  - **Rule Scope** — scope the resulting rule to the entire process, or to just the specific remote destination.
  - **Rule Duration** — choose whether the rule lasts forever, only for the lifetime of this instance of the process, or until a specific future time.

## Rules

Rules determine whether a connection is allowed or blocked. The Rules window lets you filter by type:

- **All Rules** — every rule mFirewall currently has: the combination of default, Apple, baseline, user, and recent rules.
- **Default Rules** — rules for Apple/macOS processes that must be allowed network access to preserve system functionality.
- **Apple Rules** — when "Allow Apple Programs" is enabled, any process signed solely by Apple is automatically allowed; those rules show up here.
- **3rd-Party Program Rules** — when "Allow Installed Programs" is enabled, apps/programs that were already installed at setup time are automatically allowed; those rules show up here.
- **User Rules** — rules you created yourself, either via "Add Rule" or by clicking Block/Allow in an alert.
- **Recent Rules** — rules created in the last 24 hours.

### Adding rules manually

Specify:
- the program's path (or `*` for all programs)
- the remote address/domain (this can be a regular expression — check the "regex" box if so)
- the remote port
- the action: Block or Allow

### Editing / deleting

Double-click a rule (or use the row's menu) to edit it. Deleting a row that represents a program removes *all* of that program's rules.

### Import / export

Via the Rules menu: exporting saves the full current rule set; importing replaces the entire rule set.

## Settings

Accessible from the status-bar menu or the main app window.

**Rules tab**
- **Allow Apple Programs** — automatically allow processes signed solely by Apple.
- **Allow Installed Applications** — automatically allow applications (and their components) that were already installed.
- **Allow DNS Traffic** — allow UDP traffic on port 53.
- **Allow Simulator Applications** — allow traffic from simulator apps.

**Modes tab**
- **Passive Mode** — mFirewall runs silently, applying existing rules without showing alerts.
- **Block Mode** — all traffic routed through mFirewall is blocked.
- **No Icon Mode** — mFirewall runs without a status-bar icon.
- **No VirusTotal Mode** — disables the VirusTotal button in alerts.

**Lists tab**
Specify allow/block lists as a newline-separated list of hosts and/or IP addresses, from a local file or a remote URL. If both an allow list and a block list are specified, the block list takes priority. Note: blocking by host name only applies to connections made via `Network.framework` or `NSURLSession`.

**Update tab**
Check for new versions, or disable automatic update checks.

## Profiles

A profile defines a set of rules and settings. Once activated, its settings apply mFirewall-wide (and can still be tweaked via the Settings panes). New rules are added only to the active profile's rule set.

- **Switch profiles** — from the Profiles pane, or directly from the status-bar menu.
- **Add a profile** — click "Add Profile" in the Profiles pane.
- **Delete a profile** — click a profile's `x` button in the Profiles pane. The default profile cannot be deleted.

## Network Monitor

Click "Network Monitor" in the status-bar menu to launch Netiquette, a network-monitor app bundled with mFirewall for deeper traffic visibility.

## Quitting / Uninstalling

Both are available from the status-bar menu and require authentication.

## FAQ

**Do I need mFirewall if I've turned on the built-in macOS firewall?**
Yes. Apple's built-in firewall only blocks incoming connections. mFirewall is designed to detect and block unauthorized *outgoing* connections — for example when malware attempts to reach its command & control server for tasking or exfiltration.

**Does mFirewall conflict with other (paid) macOS firewalls or security products?**
It's designed to play nicely alongside other security tools, though testing against every combination is inherently limited.

**I found a bug. Can it be fixed?**
Please file an issue: <https://github.com/vincentlauriat/mFirewall/issues>

**Why does mFirewall try to access the network?**
On startup, mFirewall checks for a new version by requesting `products.json` from `lauriat.fr`. No user or product information is collected or transmitted. Separately, mFirewall may generate network traffic related to VirusTotal integration: only when you click the "VirusTotal" button in an alert does it send a request containing the relevant file's hash to VirusTotal.

## Links

- Source & issues: <https://github.com/vincentlauriat/mFirewall>
- Product page: <https://lauriat.fr/outils/mfirewall>

---

mFirewall is a fork/rebrand of [LuLu](https://github.com/objective-see/LuLu) by Patrick Wardle / [Objective-See](https://objective-see.org). This guide adapts Objective-See's original LuLu documentation for mFirewall.
