#!/bin/bash

# Navigate to script's directory
cd "$(dirname "$0")"

echo "======================================"
echo " Starting SafeTrack Bus Booking System "
echo "======================================"

# 1. Check/Install JavaFX from Maven Central (Fast CDN)
if [ ! -d "javafx_lib" ]; then
    echo "Downloading JavaFX dependencies for macOS aarch64..."
    mkdir -p javafx_lib
    cd javafx_lib
    VERSION="21.0.1"
    for module in base controls fxml graphics; do
        curl -sLO "https://repo1.maven.org/maven2/org/openjfx/javafx-${module}/${VERSION}/javafx-${module}-${VERSION}.jar"
        curl -sLO "https://repo1.maven.org/maven2/org/openjfx/javafx-${module}/${VERSION}/javafx-${module}-${VERSION}-mac-aarch64.jar"
    done
    cd ..
    echo "JavaFX Downloaded."
fi

# Compile the source files
echo "Compiling application..."
mkdir -p out
javac --module-path javafx_lib --add-modules javafx.controls,javafx.fxml -cp "lib/*" -d out $(find src -name "*.java")

if [ $? -eq 0 ]; then
    echo "Compilation successful. Launching..."
    # Run the application
    java --module-path javafx_lib --add-modules javafx.controls,javafx.fxml -cp "out:lib/*" com.safetrack.main.Main
else
    echo "Compilation failed. Please check the errors above."
fi
