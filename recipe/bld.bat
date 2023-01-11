
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
