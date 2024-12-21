#!/usr/bin/env bash
set -e

mkdir -p $HOME/.local/share/applications
mkdir -p $HOME/Desktop

# For Fluxbox
FLUXBOX_MENU="$HOME/.fluxbox/menu"
if [[ -f "$FLUXBOX_MENU" ]]; then
	echo "Fluxbox detected - prepping menu edits."
	TMPFLUXMENU="/tmp/ff_fluxmenu"
	> "$TMPFLUXMENU"
	echo "    [submenu] (Firefox Variants) {}" >> "$TMPFLUXMENU"
fi

# In case a prior installation has failed.
sudo rm -rf /opt/firefox

declare -A firefox_versions=(
	["firefox-regular"]="firefox-latest"
	["firefox-esr"]="firefox-esr-latest"
	["firefox-nightly"]="firefox-nightly-latest"
	["firefox-developer"]="firefox-devedition-latest"
)

for version in "${!firefox_versions[@]}"; do
	product=${firefox_versions[$version]}
	existed=0

	echo ""
	echo "🦊 Installing: ${version}"
	echo "---------------------------------------"

	if [ -d "/opt/${version}" ]; then
		existed=1
		echo "ℹ️  Detected existing install, reinstalling..."
		echo "> sudo rm -r \"/opt/${version}\""
		sudo rm -r "/opt/${version}"
	fi

	if [ ! -f "/opt/${version}.download" ]; then
		echo "> wget -q -O \"/opt/${version}.download\" \"https://download.mozilla.org/?product=${product}&os=linux64&lang=en-US\""
		sudo wget -q -O "/opt/${version}.download" "https://download.mozilla.org/?product=${product}&os=linux64&lang=en-US"
	else
		echo "ℹ️  ${version} has already been downloaded. Skipping..."
	fi

	echo "> sudo tar -xf \"/opt/${version}.download\" -C /opt"
	sudo tar -xf "/opt/${version}.download" -C /opt

	echo "> sudo mv /opt/firefox \"/opt/${version}\""
	sudo mv /opt/firefox "/opt/${version}"

	# For Fluxbox
	if [[ -f "$FLUXBOX_MENU" ]]; then
		echo "        [exec] ($version) {/opt/${version}/firefox -P ${version}}" >> "$TMPFLUXMENU"
	fi

	if [ $existed -eq 0 ]; then
		echo "> ln -sf \"/opt/${version}/firefox\" \"/usr/local/bin/${version}\""
		sudo ln -sf "/opt/${version}/firefox" "/usr/local/bin/${version}"

	
		echo "> /opt/${version}/firefox -CreateProfile $version"
		/opt/${version}/firefox -CreateProfile $version -Headless
		exit_status=$?

		if [ $exit_status -eq 0 ]; then
			DIR="$(find $HOME/.mozilla/firefox -maxdepth 1 -type d -name "*.${version}")"
			echo $DIR >> /opt/ff-dirs
			#echo "> ln -sf \"${OP_PATH}/IE6/chrome\" \"${DIR}/chrome\""
			#ln -sf "${OP_PATH}/IE6/chrome" "${DIR}/chrome"
		else
			echo "❌ A problem occurred during profile creation. Skipping ${version}..."
		fi
	else
		echo "ℹ️  Since ${version} was already installed, let's skip the gubbins."
	fi
done

if [[ -f "$FLUXBOX_MENU" ]]; then
	echo "Editing fluxbox menu."
	echo "    [end]" >> "$TMPFLUXMENU"
	sed -i "/^\[begin\] (\s*Application Menu\s*)/r $TMPFLUXMENU" "$FLUXBOX_MENU"
	rm "$TMPFLUXMENU"
fi

echo ""
echo "🚀 Script has concluded - Firefox (of various variants) installed!"

cat << 'EOF' > "/usr/local/bin/ff-installer-link"
#!/usr/bin/env bash

create_user_settings() {
	local path="$1"

	cat << EOM > "${path}/user.js"
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.compactmode.show", true);
user_pref("browser.toolbars.bookmarks.visibility", "always");
user_pref("devtools.debugger.remote-enabled", true);
user_pref("devtools.chrome.enabled", true);
user_pref("browser.uidensity", 1);
user_pref("browser.tabs.inTitlebar", 0);
EOM
}

FILE="/opt/ff-dirs"
SOURCE_DIR="${1:-$(pwd)}"

if [ ! -f "$FILE" ]; then
	echo "Error: File '$FILE' not found."
	exit 1
fi

while IFS= read -r line; do
	if [ -d "$line" ]; then
		ln -sf "$SOURCE_DIR" "$line/chrome"
		echo "Symlink created for $line/chrome"
		create_user_settings "$line"
	else
		echo "Directory $line does not exist. Skipping..."
	fi
done < "$FILE"
EOF

chmod +x "/usr/local/bin/ff-installer-link"
