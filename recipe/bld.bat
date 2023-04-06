
cd %SRC_DIR%\sources\shiboken6

cmake -LAH -G "Ninja"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"          ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"       ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"           ^
    -DCMAKE_BUILD_TYPE=Release                      ^
    -DBUILD_TESTS=OFF                               ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                  ^
    .
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

mkdir %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info
type nul > %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info\METADATA

cd %SRC_DIR%\sources\pyside6

cmake -LAH -G "Ninja"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"          ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"       ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"           ^
    -DCMAKE_BUILD_TYPE=Release                      ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                  ^
    .
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

mkdir %SP_DIR%\PySide6-%PKG_VERSION%.dist-info
type nul > %SP_DIR%\PySide6-%PKG_VERSION%.dist-info\METADATA

cd %SRC_DIR%\sources\pyside-tools
mkdir build && cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DSITE_PACKAGE="%SP_DIR:\=/%"                            ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DBUILD_TESTS=OFF                                        ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

REM Move the entry point for pyside6-rcc pyside6-uic and pyside6-designer to the right location
mkdir %SP_DIR%\PySide6\scripts
type null > %SP_DIR%\PySide6\scripts\__init__.py
move %LIBRARY_PREFIX%\bin\pyside_tool.py %SP_DIR%\PySide2\scripts\pyside_tool.py