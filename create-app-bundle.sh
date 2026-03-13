#!/bin/bash

APP_NAME="${1:-Hoist}"
BUNDLE_ID="${2:-com.iamandrii.hoist}"
VERSION="${3:-0.0}"

rm -rf "${APP_NAME}.app" && \
mkdir -p "${APP_NAME}.app/Contents/MacOS" && \
mkdir "${APP_NAME}.app/Contents/Resources" && \
cp Hoist "${APP_NAME}.app/Contents/MacOS/${APP_NAME}" && \
sed -e "s/com\.iamandrii\.hoist/${BUNDLE_ID}/" \
    -e "s/<string>Hoist<\/string>/<string>${APP_NAME}<\/string>/g" \
    Info.plist > "${APP_NAME}.app/Contents/Info.plist" && \
plutil -replace CFBundleShortVersionString -string "${VERSION}" "${APP_NAME}.app/Contents/Info.plist" && \
cp Hoist.icns "${APP_NAME}.app/Contents/Resources" && \
chmod 755 "${APP_NAME}.app" && echo "Successfully created ${APP_NAME}.app"
