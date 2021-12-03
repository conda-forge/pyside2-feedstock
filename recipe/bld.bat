
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
FOR /F %%i IN ('%PYTHON% -c "from sysconfig import get_path; print(get_path('platlib'))"') DO set VARIABLE=%%i
ROBOCOPY shiboken2.dist-info "%LIBRARY_PREFIX%"\%%i\shiboken2.dist-info /e

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
"%PYTHON%" setup.py dist_info --build-type=PySide2
FOR /F %%i IN ('%PYTHON% -c "from sysconfig import get_path; print(get_path('platlib'))"') DO set VARIABLE=%%i
ROBOCOPY PySide2.dist-info "%LIBRARY_PREFIX%"\%%i\PySide2.dist-info /e

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

