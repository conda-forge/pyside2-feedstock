
set CMAKE_CONFIG="Release"

cd %SRC_DIR%\sources\shiboken2
mkdir build && cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"                    ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DBUILD_TESTS=OFF                                        ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                           ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

cd %SRC_DIR%
"%PYTHON%" setup.py dist_info --build-type=shiboken2
move shiboken2-%PKG_VERSION%.dist-info %SP_DIR%\shiboken2-%PKG_VERSION%.dist-info

cd %SRC_DIR%\sources\pyside2
mkdir build && cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"                    ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                           ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

ctest --output-on-failure --timeout 100 -E QtWebKit || echo "no ok"
rem if errorlevel 1 exit 1

cd %SRC_DIR%
"%PYTHON%" setup.py dist_info --build-type=pyside2
move PySide2-%PKG_VERSION%.dist-info %SP_DIR%\PySide2-%PKG_VERSION%.dist-info

cd %SRC_DIR%\sources\pyside2-tools
mkdir build && cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DSITE_PACKAGE="%SP_DIR:\=/%"                            ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DBUILD_TESTS=OFF                                        ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

REM Move the entry point for pyside2-rcc pyside2-uic and pyside2-designer to the right location
mkdir %SP_DIR%\PySide2\scripts
type null > %SP_DIR%\PySide2\scripts\__init__.py
move %LIBRARY_PREFIX%\bin\pyside_tool.py %SP_DIR%\PySide2\scripts\pyside_tool.py
