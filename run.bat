@echo off
setlocal EnableExtensions

rem Always run from the directory containing this script.
cd /d "%~dp0"

echo ======================================
echo  Starting SafeTrack Bus Booking System
echo ======================================

rem Verify that a full JDK is available.
where java >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java is not installed or is not available in PATH.
    echo Install JDK 21 or newer, then open a new terminal.
    pause
    exit /b 1
)

where javac >nul 2>&1
if errorlevel 1 (
    echo ERROR: javac was not found. A JDK is required, not only a JRE.
    echo Install JDK 21 or newer, then open a new terminal.
    pause
    exit /b 1
)

if not exist "lib\mysql-connector-j-8.3.0.jar" (
    echo ERROR: lib\mysql-connector-j-8.3.0.jar is missing.
    pause
    exit /b 1
)

rem Keep Windows JavaFX libraries separate from the bundled macOS ARM files.
set "JAVAFX_VERSION=21.0.1"
set "JAVAFX_DIR=javafx_lib_windows"
set "JAVAFX_BASE_URL=https://repo1.maven.org/maven2/org/openjfx"

if not exist "%JAVAFX_DIR%" mkdir "%JAVAFX_DIR%"

for %%M in (base controls fxml graphics) do call :download_javafx %%M

for %%M in (base controls fxml graphics) do (
    if not exist "%JAVAFX_DIR%\javafx-%%M-%JAVAFX_VERSION%.jar" (
        echo ERROR: Missing JavaFX module javafx-%%M-%JAVAFX_VERSION%.jar
        pause
        exit /b 1
    )
    if not exist "%JAVAFX_DIR%\javafx-%%M-%JAVAFX_VERSION%-win.jar" (
        echo ERROR: Missing Windows JavaFX module javafx-%%M-%JAVAFX_VERSION%-win.jar
        pause
        exit /b 1
    )
)

if not exist "out" mkdir "out"

set "SOURCE_LIST=%TEMP%\safetrack-sources-%RANDOM%-%RANDOM%.txt"
(for /r "%CD%\src" %%F in (*.java) do @echo "%%F") > "%SOURCE_LIST%"

echo Compiling application...
javac --module-path "%JAVAFX_DIR%" ^
      --add-modules javafx.controls,javafx.fxml ^
      -cp "lib\*" ^
      -d "out" ^
      @"%SOURCE_LIST%"

set "COMPILE_RESULT=%ERRORLEVEL%"
del "%SOURCE_LIST%" >nul 2>&1

if not "%COMPILE_RESULT%"=="0" (
    echo Compilation failed. Review the errors above.
    pause
    exit /b %COMPILE_RESULT%
)

echo Compilation successful. Launching...
java --module-path "%JAVAFX_DIR%" ^
     --add-modules javafx.controls,javafx.fxml ^
     -cp "out;lib\*" ^
     com.safetrack.main.Main

if errorlevel 1 (
    echo.
    echo Application exited with an error.
    pause
    exit /b 1
)

exit /b 0

:download_javafx
set "MODULE=%~1"
set "COMMON_JAR=javafx-%MODULE%-%JAVAFX_VERSION%.jar"
set "WINDOWS_JAR=javafx-%MODULE%-%JAVAFX_VERSION%-win.jar"
set "MODULE_URL=%JAVAFX_BASE_URL%/javafx-%MODULE%/%JAVAFX_VERSION%"

if not exist "%JAVAFX_DIR%\%COMMON_JAR%" (
    echo Downloading %COMMON_JAR%...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Invoke-WebRequest -UseBasicParsing -Uri '%MODULE_URL%/%COMMON_JAR%' -OutFile '%JAVAFX_DIR%\%COMMON_JAR%'"
)

if not exist "%JAVAFX_DIR%\%WINDOWS_JAR%" (
    echo Downloading %WINDOWS_JAR%...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Invoke-WebRequest -UseBasicParsing -Uri '%MODULE_URL%/%WINDOWS_JAR%' -OutFile '%JAVAFX_DIR%\%WINDOWS_JAR%'"
)

exit /b 0
