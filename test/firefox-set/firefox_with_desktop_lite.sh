#!/bin/bash

# This test runs against the firefox_with_desktop_lite scenario declared in
# test/firefox-set/scenarios.json.

set -e

source dev-container-features-test-lib

check "firefox-regular installed" test -x /opt/firefox-regular/firefox
check "firefox-esr installed" test -x /opt/firefox-esr/firefox
check "firefox-nightly installed" test -x /opt/firefox-nightly/firefox
check "firefox-developer installed" test -x /opt/firefox-developer/firefox

check "profiles file exists" test -f /opt/ff-dirs
check "profiles include regular" bash -c "grep -q '\\.firefox-regular$' /opt/ff-dirs"
check "profiles include esr" bash -c "grep -q '\\.firefox-esr$' /opt/ff-dirs"
check "profiles include nightly" bash -c "grep -q '\\.firefox-nightly$' /opt/ff-dirs"
check "profiles include developer" bash -c "grep -q '\\.firefox-developer$' /opt/ff-dirs"
check "all profile directories exist" bash -c 'while IFS= read -r p; do test -d "$p"; done < /opt/ff-dirs'

reportResults
