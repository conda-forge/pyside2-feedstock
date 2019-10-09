#!/bin/sh

XVFB_RUN=""
if test `uname` = "Linux"
then
  XVFB_RUN="xvfb-run -s '-screen 0 640x480x24'"
fi

# https://github.com/conda-forge/qt-feedstock/issues/123
if test `uname` = "Linux"
then
  sed -i 's|_qt5gui_find_extra_libs(EGL.*)|_qt5gui_find_extra_libs(EGL "EGL" "" "")|g' $PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake
  sed -i 's|_qt5gui_find_extra_libs(OPENGL.*)|_qt5gui_find_extra_libs(OPENGL "GL" "" "")|g' $PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake
fi

pushd sources/shiboken2
mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DBUILD_TESTS=OFF \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  ..
make install -j${CPU_COUNT}
popd
# 
# pushd sources/pyside2
# mkdir build && cd build
# 
# cmake \
#   -DCMAKE_PREFIX_PATH=${PREFIX} \
#   -DCMAKE_INSTALL_PREFIX=${PREFIX} \
#   -DCMAKE_BUILD_TYPE=Release \
#   -DPYTHON_EXECUTABLE=${PYTHON} \
#   -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
#   ..
# make install -j${CPU_COUNT}
# 
# cp ./tests/pysidetest/libpysidetest${SHLIB_EXT} ${PREFIX}/lib
# # create a single X server connection rather than one for each test using the PySide USE_XVFB cmake option
# eval ${XVFB_RUN} ctest -j${CPU_COUNT} --output-on-failure --timeout 200 -E QtWebKit || echo "no ok"
# popd
# 
# pushd sources/pyside2-tools
# mkdir build && cd build
# 
# cmake \
#   -DCMAKE_PREFIX_PATH=${PREFIX} \
#   -DCMAKE_INSTALL_PREFIX=${PREFIX} \
#   -DCMAKE_BUILD_TYPE=Release \
#   -DBUILD_TESTS=OFF \
#   ..
# make install -j${CPU_COUNT}

pushd ${RECIPE_DIR}/cmake_shiboken
mkdir build && cd build
cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  ..
make install -j${CPU_COUNT}
./hello
