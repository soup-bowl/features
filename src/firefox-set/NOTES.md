## Additional requirements

This feature **requires** the [official desktop-lite feature](https://github.com/devcontainers/features/tree/main/src/desktop-lite), which it will build upon.

For this script to work fully, you will need to execute a follow-up command that symlinks your chrome directory into the chrome of all four installations. This way you can make changes to your source code, and they will be reflected in all editions. Here's an example from the [Modoki-Firefox theme](https://github.com/soup-bowl/Modoki-Firefox).

```json
{
	"name": "Firefox",
	"image": "mcr.microsoft.com/devcontainers/base:jammy",
	"features": {
		"ghcr.io/devcontainers/features/desktop-lite:1": {
			"password": "noPassword"
		},
		"ghcr.io/soup-bowl/features/firefox-set:latest": {}
	},
	"forwardPorts": [6080],
	"postCreateCommand": "ff-installer-link $(pwd)/IE6/chrome",
	"remoteUser": "root"
}
```

## Installed versions

This script will install the following versions of Firefox:

* [Firefox](https://www.mozilla.org/en-GB/firefox/new/)
* [firefox ESR](https://www.mozilla.org/en-GB/firefox/enterprise/)
* [Firefox Developer](https://www.mozilla.org/en-GB/firefox/developer/)
* [Firefox Nightly](https://www.mozilla.org/en-GB/firefox/channel/desktop/#nightly)

The script will add them to the Fluxbox menu, available under the **Firefox variants** submenu. All browsers are configured to allow inspection of the browser, and enabling other settings typically used for custom themes.
