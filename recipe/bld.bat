
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

rem  cd %SRC_DIR%\sources\pyside2
rem  mkdir build && cd build
rem  
rem  cmake -LAH -G"NMake Makefiles"                               ^
rem      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
rem      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
rem      -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"                    ^
rem      -DCMAKE_BUILD_TYPE=Release                               ^
rem      -DPYTHON_EXECUTABLE="%PYTHON%"                           ^
rem      ..
rem  if errorlevel 1 exit 1
rem  
rem  cmake --build . --config %CMAKE_CONFIG% --target install
rem  if errorlevel 1 exit 1
rem  
rem  ctest --output-on-failure --timeout 100 -E QtWebKit || echo "no ok"
rem  rem if errorlevel 1 exit 1
rem  
rem  cd %SRC_DIR%\sources\pyside2-tools
rem  mkdir build && cd build
rem  
rem  cmake -LAH -G"NMake Makefiles"                               ^
rem      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
rem      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
rem      -DSITE_PACKAGE="%SP_DIR:\=/%"                            ^
rem      -DCMAKE_BUILD_TYPE=Release                               ^
rem      -DBUILD_TESTS=OFF                                        ^
rem      ..
rem  if errorlevel 1 exit 1
rem  
rem  cmake --build . --config %CMAKE_CONFIG% --target install
rem  if errorlevel 1 exit 1

rem shiboken test
cd %RECIPE_DIR%\cmake_shiboken
mkdir build && cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

hello.exe
if errorlevel 1 exit 1
