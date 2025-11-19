:: build shiboken only
cmake -LAH -G "Ninja"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"          ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"       ^
    -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"           ^
    -DCMAKE_BUILD_TYPE=Release                      ^
    -DBUILD_TESTS=OFF                               ^
    -DFORCE_LIMITED_API=OFF                         ^
    -DPython_EXECUTABLE="%PYTHON%"                  ^
    -B build_shiboken %SRC_DIR:\=/%/sources/shiboken6
if errorlevel 1 exit 1

cmake --build build_shiboken --target install
if errorlevel 1 exit 1

:: write dummy shiboken metadata
mkdir %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info
copy %RECIPE_DIR%\METADATA.shiboken6.in %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info\METADATA
echo Version: %PKG_VERSION% >> %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info\METADATA
type %SP_DIR%\shiboken6-%PKG_VERSION%.dist-info\METADATA

:: build all
cmake -LAH -G "Ninja"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"          ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"       ^
    -DCMAKE_UNITY_BUILD=ON                          ^
    -DCMAKE_UNITY_BUILD_BATCH_SIZE=32               ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"           ^
    -DCMAKE_BUILD_TYPE=Release                      ^
    -DBUILD_TESTS=OFF                               ^
    -DFORCE_LIMITED_API=OFF                         ^
    -DPython_EXECUTABLE="%PYTHON%"                  ^
    -DNO_QT_TOOLS=yes                               ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install
if errorlevel 1 exit 1

:: write dummy pyside metadata
mkdir %SP_DIR%\PySide6-%PKG_VERSION%.dist-info
copy %RECIPE_DIR%\METADATA.pyside6.in %SP_DIR%\PySide6-%PKG_VERSION%.dist-info\METADATA
echo Version: %PKG_VERSION% >> %SP_DIR%\PySide6-%PKG_VERSION%.dist-info\METADATA
type %SP_DIR%\PySide6-%PKG_VERSION%.dist-info\METADATA

:: Move pyside_tool.py to the right location
mkdir %SP_DIR%\PySide6\scripts
type nul > %SP_DIR%\PySide6\scripts\__init__.py
move %LIBRARY_PREFIX%\bin\pyside_tool.py %SP_DIR%\PySide6\scripts\pyside_tool.py
