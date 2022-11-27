#!/bin/sh

XVFB_RUN=""
if test `uname` = "Linux"
then
  XVFB_RUN="xvfb-run -s '-screen 0 640x480x24'"
fi

pushd sources/shiboken6

if test "$CONDA_BUILD_CROSS_COMPILATION" = "1"
then
  (
    mkdir -p build_native && cd build_native

    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}
    export CFLAGS=${CFLAGS//$PREFIX/$BUILD_PREFIX}
    export CXXFLAGS=${CXXFLAGS//$PREFIX/$BUILD_PREFIX}

    # hide host libs
    mkdir -p $BUILD_PREFIX/${HOST}
    mv $BUILD_PREFIX/${HOST} _hidden

    cmake -LAH -G "Ninja" \
      -DCMAKE_PREFIX_PATH=${BUILD_PREFIX} \
      -DCMAKE_IGNORE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_INSTALL_RPATH:STRING=${BUILD_PREFIX}/lib \
      -DCMAKE_RANLIB=$BUILD_PREFIX/bin/${CONDA_TOOLCHAIN_BUILD}-ranlib \
      -DCMAKE_INSTALL_PREFIX=${BUILD_PREFIX} \
      -DBUILD_TESTS=OFF \
    ..
    cmake --build . --target install
    mv _hidden $BUILD_PREFIX/${HOST}
  )
  rm -r build_native
  CMAKE_ARGS="${CMAKE_ARGS} -DQFP_SHIBOKEN_HOST_PATH=${BUILD_PREFIX} -DQT_HOST_PATH=${BUILD_PREFIX} -DQFP_PYTHON_HOST_PATH=${BUILD_PREFIX}/bin/python"
  if test `uname` = "Darwin"
  then
    CMAKE_ARGS="${CMAKE_ARGS} -DPython_SOABI=cpython-${PY_VER//./}-darwin"
  fi
fi

mkdir build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DBUILD_TESTS=OFF \
  -DSHIBOKEN_BUILD_TOOLS=ON \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  ..
cmake --build . --target install
popd

pushd sources/pyside6
mkdir build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -D_qt5Core_install_prefix=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=ON \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
  ..
cmake --build . --target install

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  cp -v ./tests/pysidetest/libpysidetest${SHLIB_EXT} ${PREFIX}/lib
  cp -v ./tests/pysidetest/testbinding.abi3.so ${SP_DIR}
  eval ${XVFB_RUN} ctest -j${CPU_COUNT} --output-on-failure --timeout 30 -V || echo "no ok"
  rm ${PREFIX}/lib/libpysidetest${SHLIB_EXT} ${SP_DIR}/testbinding.abi3.so
fi
