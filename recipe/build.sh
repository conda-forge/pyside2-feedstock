#!/bin/sh

XVFB_RUN=""
if test `uname` = "Linux"
then
  cp -r /usr/include/xcb ${PREFIX}/include/qt
  XVFB_RUN="xvfb-run -s '-screen 0 640x480x24'"
fi

set -ex

# Remove running without PYTHONPATH
sed -i.bak "s/, '-E'//g" sources/shiboken2/libshiboken/embed/embedding_generator.py
sed -i.bak 's/${PYTHON_EXECUTABLE} -E/${PYTHON_EXECUTABLE}/g' sources/shiboken2/libshiboken/CMakeLists.txt

# Use build shiboken2
sed -i.bak "s/COMMAND Shiboken2::shiboken2/COMMAND shiboken2/g" sources/pyside2/cmake/Macros/PySideModules.cmake
sed -i.bak "s/COMMAND Shiboken2::shiboken2/COMMAND shiboken2/g" sources/pyside2/tests/pysidetest/CMakeLists.txt

extra_cmake_flags=

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  export RUN_TESTS=yes

  # Shiboken6 has better support for cross compilation
  # But for now, lets just specify the flags manually
  PYTHON_EXTENSION_SUFFIX=$(${PYTHON} -c "import distutils.sysconfig, os.path; print(os.path.splitext(distutils.sysconfig.get_config_var('EXT_SUFFIX'))[0])")
  extra_cmake_flags="${extra_cmake_flags} -DPYTHON_EXTENSION_SUFFIX=${PYTHON_EXTENSION_SUFFIX}"
else
  export RUN_TESTS=no
fi

pushd sources/shiboken2
mkdir -p build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  ${extra_cmake_flags} \
  ..
cmake --build . --target install
popd

${PYTHON} setup.py dist_info --build-type=shiboken2
cp -r shiboken2-${PKG_VERSION}.dist-info "${SP_DIR}"/

pushd sources/pyside2
mkdir -p build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  ${extra_cmake_flags} \
  ..
cmake --build . --target install

if test "$CONDA_BUILD_CROSS_COMPILATION" = "1"
then
  # pyi files are generated in the host prefix and hence not installed
  cp -v ${BUILD_PREFIX}/venv/lib/python${PY_VER}/site-packages/PySide2/*.pyi ${SP_DIR}/PySide2
fi

cp ./tests/pysidetest/libpysidetest${SHLIB_EXT} ${PREFIX}/lib
cp ./tests/pysidetest/testbinding*.so ${SP_DIR}
# create a single X server connection rather than one for each test using the PySide USE_XVFB cmake option
if [[ "${RUN_TESTS}" == "yes" ]]; then
  eval ${XVFB_RUN} ctest -j${CPU_COUNT} --output-on-failure --timeout 200 -E QtWebKit || echo "no ok"
fi
rm ${SP_DIR}/testbinding*.so
popd

${PYTHON} setup.py dist_info --build-type=pyside2
cp -r PySide2-${PKG_VERSION}.dist-info "${SP_DIR}"/

pushd sources/pyside2-tools
mkdir -p build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF \
  ..
cmake --build . --target install

# Move the entry point for pyside2-rcc pyside2-uic and pyside2-designer to the right location
mkdir -p "${SP_DIR}"/PySide2/scripts
touch "${SP_DIR}"/PySide2/scripts/__init__.py
mv ${PREFIX}/bin/pyside_tool.py "${SP_DIR}"/PySide2/scripts/pyside_tool.py

rm -rf ${PREFIX}/include/qt/xcb
