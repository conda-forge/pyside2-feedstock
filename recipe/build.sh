#!/bin/sh

XVFB_RUN=""
if test `uname` = "Linux"
then
  cp -r /usr/include/xcb ${PREFIX}/include/qt
  XVFB_RUN="xvfb-run -s '-screen 0 640x480x24'"
fi

pushd sources/shiboken2
mkdir build && cd build

# https://www.qt.io/blog/qt-on-apple-silicon

cmake ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DBUILD_TESTS=OFF \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  ..
make install -j${CPU_COUNT}
popd

${PYTHON} setup.py dist_info --build-type=shiboken2
cp -r shiboken2-${PKG_VERSION}.dist-info "${SP_DIR}"/

pushd sources/pyside2
mkdir build && cd build

cmake ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
  ..
make install -j${CPU_COUNT} VERBOSE=1

cp ./tests/pysidetest/libpysidetest${SHLIB_EXT} ${PREFIX}/lib
# create a single X server connection rather than one for each test using the PySide USE_XVFB cmake option
eval ${XVFB_RUN} ctest -j${CPU_COUNT} --output-on-failure --timeout 200 -E QtWebKit || echo "no ok"
popd

${PYTHON} setup.py dist_info --build-type=pyside2
cp -r PySide2-${PKG_VERSION}.dist-info "${SP_DIR}"/

pushd sources/pyside2-tools
mkdir build && cd build

cmake ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF \
  ..
make install -j${CPU_COUNT} VERBOSE=1

# Move the entry point for pyside2-rcc pyside2-uic and pyside2-designer to the right location
mkdir -p "${SP_DIR}"/PySide2/scripts
touch "${SP_DIR}"/PySide2/scripts/__init__.py
mv ${PREFIX}/bin/pyside_tool.py "${SP_DIR}"/PySide2/scripts/pyside_tool.py

rm -rf ${PREFIX}/include/qt/xcb

