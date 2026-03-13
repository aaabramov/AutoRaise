#!/bin/bash

APP_NAME="${1:-AutoRaise}"
BUNDLE_ID="${2:-nl.postware.autoraise}"

rm -rf "${APP_NAME}.app" && \
mkdir -p "${APP_NAME}.app/Contents/MacOS" && \
mkdir "${APP_NAME}.app/Contents/Resources" && \
cp AutoRaise "${APP_NAME}.app/Contents/MacOS/${APP_NAME}" && \
sed -e "s/nl\.postware\.autoraise/${BUNDLE_ID}/" \
    -e "s/<string>AutoRaise<\/string>/<string>${APP_NAME}<\/string>/g" \
    Info.plist > "${APP_NAME}.app/Contents/Info.plist" && \
cp AutoRaise.icns "${APP_NAME}.app/Contents/Resources" && \
chmod 755 "${APP_NAME}.app" && echo "Successfully created ${APP_NAME}.app"
