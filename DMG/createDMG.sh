VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "Release/mFirewall.app/Contents/Info.plist")

printf "\nCreating mFirewall Disk Image...\n\n"

#remove any old ones
rm -f mFirewall_*.dmg

create-dmg \
  --volname "mFirewall v$VERSION" \
  --volicon "mFirewall.icns" \
  --background "background.png" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "mFirewall.app" 200 190 \
  --hide-extension "mFirewall.app" \
  --app-drop-link 600 190 \
  "mFirewall_$VERSION.dmg" \
  "Release/"

printf "\nCode signing dmg...\n"

#code sign
codesign --force --sign "Developer ID Application: Vincent LAURIAT (KFLACS69T9)" mFirewall_$VERSION.dmg

printf "Done!\n"
