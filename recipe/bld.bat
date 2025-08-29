
cd %SRC_DIR%\sources\shiboken6

cmake -LAH -G "Ninja"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"          ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"       ^
    -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 ^
    -DFORCE_LIMITED_API=OFF                         ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"           ^
    -DCMAKE_BUILD_TYPE=Release                      ^
    -DBUILD_TESTS=OFF                               ^
    -DFORCE_LIMITED_API=OFF                         ^
    -DPython_EXECUTABLE="%PYTHON%"                  ^
    .
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

mkdir %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info
copy %RECIPE_DIR%\METADATA.shiboken6.in %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info\METADATA
echo Version: %PKG_VERSION% >> %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info\METADATA

cd %SRC_DIR%\sources\pyside6

cmake -LAH -G "Ninja"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"          ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"       ^
    -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"           ^
    -DCMAKE_BUILD_TYPE=Release                      ^
    -DPython_EXECUTABLE="%PYTHON%"                  ^
    .
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

mkdir %SP_DIR%\PySide6-%PKG_VERSION%.dist-info
copy %RECIPE_DIR%\METADATA.pyside6.in %SP_DIR%\PySide6-%PKG_VERSION%.dist-info\METADATA
echo Version: %PKG_VERSION% >> %SP_DIR%\PySide6-%PKG_VERSION%.dist-info\METADATA
type %SP_DIR%\PySide6-%PKG_VERSION%.dist-info\METADATA

cd %SRC_DIR%\sources\pyside-tools
mkdir build && cd build

cmake -LAH -G"Ninja"                                ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"          ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"       ^
    -DCMAKE_BUILD_TYPE=Release                      ^
    -DNO_QT_TOOLS=yes                               ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

:: Move pyside_tool.py to the right location
mkdir %SP_DIR%\PySide6\scripts
type nul > %SP_DIR%\PySide6\scripts\__init__.py
move %LIBRARY_PREFIX%\bin\pyside_tool.py %SP_DIR%\PySide6\scripts\pyside_tool.py
