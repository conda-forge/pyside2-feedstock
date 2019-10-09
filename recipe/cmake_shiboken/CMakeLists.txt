

cmake_minimum_required (VERSION 2.8.12)

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the build type")

if(POLICY CMP0025)
  cmake_policy(SET CMP0025 NEW)
endif()

project (cmake_shiboken)

find_package(Shiboken2 NO_MODULE REQUIRED)

add_executable (hello main.cxx)

target_link_libraries (hello Shiboken2::libshiboken)

install (TARGETS hello DESTINATION bin)
