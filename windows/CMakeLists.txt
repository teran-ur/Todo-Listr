cmake_minimum_required(VERSION 3.14)
project(todo_app LANGUAGES CXX)

set(BINARY_NAME "todo_app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "Profile")
endif()

# Enable Unicode standard
add_definitions(-DUNICODE -D_UNICODE)

add_subdirectory(flutter)

add_executable(${BINARY_NAME} WIN32
  "runner/main.cpp"
  "runner/utils.cpp"
  "runner/win32_window.cpp"
  "runner/flutter_window.cpp"
  "runner/Runner.rc"
  "runner/runner.exe.manifest"
)

apply_standard_cpp_compiler_flags(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
