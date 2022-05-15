#!/bin/sh

XVFB_RUN=""
if test `uname` = "Linux"
then
  cp -r /usr/include/xcb ${PREFIX}/include/qt
  XVFB_RUN="xvfb-run -s '-screen 0 640x480x24'"
fi

pushd sources/pyside2
mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
  ..
make install -j${CPU_COUNT}

cp ./tests/pysidetest/libpysidetest${SHLIB_EXT} ${PREFIX}/lib
# create a single X server connection rather than one for each test using the PySide USE_XVFB cmake option
eval ${XVFB_RUN} ctest -j${CPU_COUNT} --output-on-failure --timeout 200 -E QtWebKit || echo "no ok"
popd

${PYTHON} setup.py dist_info --build-type=pyside2
_pythonpath=`${PYTHON} -c "from sysconfig import get_python_version; print(get_python_version())"`
cp -r PySide2-5.15.3.dist-info "${PREFIX}"/lib/python"${_pythonpath}"/site-packages/

pushd sources/pyside2-tools
mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF \
  ..
make install -j${CPU_COUNT}

# Move the entry point for pyside2-rcc pyside2-uic and pyside2-designer to the right location
mkdir -p "${PREFIX}"/lib/python"${_pythonpath}"/site-packages/PySide2/scripts
touch "${PREFIX}"/lib/python"${_pythonpath}"/site-packages/PySide2/scripts/__init__.py
mv ${PREFIX}/bin/pyside_tool.py "${PREFIX}"/lib/python"${_pythonpath}"/site-packages/PySide2/scripts/pyside_tool.py
# This is just an extra file that doesn't do anything. Shiboken Doesn't have any entry points
rm ${PREFIX}/bin/shiboken_tool.py

if test `uname` = "Linux"
then
  rm -rf ${PREFIX}/include/qt/xcb
fi

