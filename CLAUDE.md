# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

mFirewall is a free, open-source macOS firewall. It is a fork/rebrand of [LuLu](https://github.com/objective-see/LuLu) by Patrick Wardle / Objective-See — see [README.md](README.md) for attribution. It is 100% Objective-C (no Swift), built with AppKit/XIBs (no SwiftUI), licensed under GPLv3.

Identity used throughout the project: bundle ID prefix `fr.lauriat.mfirewall`, Developer ID team `KFLACS69T9` (`Developer ID Application: Vincent LAURIAT (KFLACS69T9)`). These replace the original project's `com.objective-see.lulu` / `VBG97UB4TA` (Objective-See's own team).

## Build

There is no XcodeGen (`project.yml`), no `Makefile`, and no `Scripts/` directory. Build directly via Xcode or `xcodebuild` against the workspace/project:

```bash
xcodebuild -workspace mfirewall.xcworkspace -scheme mFirewall -configuration Debug build
xcodebuild -workspace mfirewall.xcworkspace -scheme Extension -configuration Debug build
```

Only two schemes are checked in (`mFirewall`, `Extension`) — there is a third `TestExtension` target in `project.pbxproj` but no scheme for it, so it isn't normally built. `MACOSX_DEPLOYMENT_TARGET` is `26.0` (raised from `10.15` as part of the Liquid Glass UX rework — a deliberate product decision that drops support for macOS <26), which also happens to match what the Xcode-beta SDK on this machine requires; no manual override needed for local builds.

The App target copies `Binaries/Netiquette.app` into the built app as a resource; that binary is not checked into this repo (`mFirewall/Binaries/` is gitignored — same as upstream), so a resource-copy build step will fail until it's placed there manually. This is a pre-existing repo characteristic, not specific to this fork.

Because the Extension target is a macOS **System Extension** (not a LaunchDaemon), a normal `xcodebuild` run cannot fully install/activate it standalone — installing/upgrading the extension on a real machine requires signing, `SystemExtensions` approval in System Settings, and a reboot/reload cycle. Prefer verifying logic changes via the standalone test harness (see below) or by reasoning through the code rather than assuming a local build proves end-to-end behavior.

### Signing/provisioning caveat

Both targets use `CODE_SIGN_STYLE = Manual` with `DEVELOPMENT_TEAM = KFLACS69T9` and `PROVISIONING_PROFILE_SPECIFIER` values (`mFirewall Application`, `mFirewall Extension`) that assume matching Developer ID provisioning profiles exist in the Apple Developer portal for bundle IDs under `fr.lauriat.mfirewall.*`, entitled for `com.apple.developer.networking.networkextension` / `system-extension.install` / the `fr.lauriat.mfirewall` App Group. A green `xcodebuild` for the App target does not guarantee the signed system extension will actually load on a Mac — that additionally depends on this Developer Portal provisioning being in place.

### Packaging (DMG)

`DMG/createDMG.sh` builds the distributable `.dmg` from an already-built Release app at `DMG/Release/mFirewall.app` — it reads `CFBundleVersion` from that app's `Info.plist`, runs `create-dmg`, then codesigns with `Developer ID Application: Vincent LAURIAT (KFLACS69T9)`. This assumes a Release build has already been produced manually; there is no end-to-end release script in this repo.

## Tests

There is no XCTest target. `mFirewall/Tests/` contains a standalone Objective-C test harness compiled directly with `clang` against `Foundation`/`NetworkExtension`:

```bash
./mFirewall/Tests/run_passive_mode_tests.sh
```

This compiles `test_passive_mode_improvements.m` to a temporary binary, runs it, and cleans up. Current coverage (9 tests) is limited to passive-mode rule creation logic: host/FQDN vs. IP prioritization and port display. When adding logic in this area, extend this file rather than introducing a new test mechanism.

## Architecture

The app is split into two Xcode targets that communicate over XPC, plus a directory of code shared between them:

- **`mFirewall/App`** — the menu-bar UI app (`fr.lauriat.mfirewall.app`, `LSUIElement=true`, no Dock icon). Owns all `WindowController`s (Alert, Rules, Prefs, AddRule, About, Welcome, Update, StatusBarItem, ...) and drives system-extension activation via `Extension.h/.m` (`OSSystemExtensionRequestDelegate`). Talks to the extension through `XPCDaemonClient.m` and exposes callbacks to it via `XPCUser.m`.
- **`mFirewall/Extension`** — the system extension (`fr.lauriat.mfirewall.extension`). This single target plays two roles at once: it's the `NEFilterDataProvider` that performs actual network filtering (`FilterDataProvider.h/.m`, the core filtering logic), *and* the privileged "daemon" that owns rules/preferences/alerts/profiles — several headers still carry a historical `project: mfirewall (launch daemon)` comment from when this logic lived in a separate LaunchDaemon (a holdover from the original LuLu codebase's `lulu (launch daemon)` labels). There is no separate daemon target in this repo. Other key classes: `Rules` (load/save/match/toggle rules), `Alerts` (create/dedupe/deliver alerts), `Process` / `Binary` (info on the process behind a flow), `GrayList`/`BlockOrAllowList`, `Profiles`, `Preferences`. Exposes `XPCListener.m` and calls back via `XPCUserClient.m`.
- **`mFirewall/Shared`** — code compiled into both targets: `Rule.h/.m` (the rule model), `XPCDaemonProto.h`/`XPCUserProto.h` (the two XPC protocols — see below), `consts.h` (bundle IDs, mach service name, signing identity, install path), `signing.h/.m`, `utilities.h/.m`.
- **`mFirewall/Tests`** — see Tests above.
- **`mFirewall/App/3rd-party`** — just `OrderedDictionary.h/.m`.

### XPC contract

Two protocols in `mFirewall/Shared` define the App↔Extension boundary:
- `XPCDaemonProtocol` (`XPCDaemonProto.h`) — methods the extension exposes to the app: `getPreferences`/`updatePreferences`, `getRules`/`addRule`/`toggleRule`/`deleteRule`/`importRules`/`cleanupRules`, `getCurrentProfile`/`getProfiles`/`addProfile`/`deleteProfile`/`setProfile`, `uninstall`.
- `XPCUserProtocol` (`XPCUserProto.h`) — methods the extension calls back into the app: `rulesChanged`, `alertShow:reply:`.

Mach service name is `KFLACS69T9.fr.lauriat.mfirewall` (`DAEMON_MACH_SERVICE` in `consts.h`), which must match `NEMachServiceName` (`$(TeamIdentifierPrefix)fr.lauriat.mfirewall`) in `Extension/Info.plist` at build time — this only resolves correctly if `DEVELOPMENT_TEAM` stays `KFLACS69T9`. Both targets share the App Group `$(TeamIdentifierPrefix)fr.lauriat.mfirewall` (see `App.entitlements` / `Extension.entitlements`) for data shared outside XPC calls. The code-signing gate in `XPCListener.m` requires connecting clients to be signed by the `SIGNING_AUTH` common name (`consts.h`) — if you ever re-sign under a different identity, that constant must be updated to match or the app's XPC connection will be rejected by the extension.

When changing the shape of a method on either protocol, update the protocol header in `Shared`, the implementation on the owning side (`XPCListener.m`/`XPCUserClient.m` in Extension, or `XPCDaemonClient.m`/`XPCUser.m` in App), and every call site — there's no codegen keeping these in sync.

### Runtime/debug

Installed runtime files live under `/Library/mFirewall` (`INSTALL_DIRECTORY` in `consts.h`). Tail extension/app logs with:

```bash
log stream --level debug --predicate="subsystem='fr.lauriat.mfirewall'"
```

## Documentation

The full user guide (installation, alerts, rules, settings, profiles, FAQ) lives in [docs/USAGE.md](docs/USAGE.md), also published at <https://lauriat.fr/outils/mfirewall>. `README.md` is a short overview that links to it.

## Known leftovers from the LuLu → mFirewall rename

- `PRODUCT_URL` (`consts.h`) points at `https://lauriat.fr/outils/mfirewall`; `ERRORS_URL`/`FATAL_ERROR_URL` at `https://lauriat.fr/outils/mfirewall/errors`. None of these pages exist yet — they need to be published there for in-app "learn more"/error links to resolve.
- `PRODUCT_VERSIONS_URL` (`consts.h`) points at `https://lauriat.fr/outils/mfirewall/products.json`, which doesn't exist yet either. Until that feed is published, the in-app update checker will just fail its request (logged via `os_log_error` in `Update.m`, non-fatal) — treat auto-update as effectively disabled, or turn it off explicitly via `PREF_NO_UPDATE_MODE`.
- `AppDelegate.m`'s "v1.0 version installed?" check (looks for `LuLu.bundle` under `INSTALL_DIRECTORY`) was deliberately left referencing the real, original LuLu — it's a legacy-conflict detector for Objective-See's own product, not a self-reference, and is effectively inert now that `INSTALL_DIRECTORY` changed.
- `StatusBarItem.m`'s Netiquette launch code still passes the literal `-lulu` argument — that's a hardcoded flag the external `Netiquette.app` binary (a separate Objective-See tool, not part of this repo) expects; changing it would break that integration.
- `mFirewall.xcodeproj`'s `Extension.xcscheme` still has a pre-existing (pre-rename) build entry referencing `container:../Uninstaller/Uninstaller.xcodeproj`, a sibling project not present in this repo.
- `ORGANIZATIONNAME` in `project.pbxproj` is still `Objective-See` (used for new-file header boilerplate in Xcode); GPL copyright/authorship headers on existing files were intentionally left untouched.
- The `mFirewallText` image asset (used in `Welcome.xib`, `AboutWindow.xib`, `Rules.xib`) was renamed from its LuLu-era slot but its bitmap content was never redrawn — it still visually renders the "LuLu" wordmark. The static onboarding help screenshots embedded in `Welcome.xib` (illustrating the "System Extension Blocked" / "would like to filter network content" system dialogs) likewise still show "LuLu" in the captured dialogs. Needs new artwork/screenshots, not a code fix.
