cmake_minimum_required(VERSION 3.20)

# Cross-compile for Windows
set(CMAKE_SYSTEM_NAME Windows)

# Toolchain
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++ CACHE STRING "" FORCE)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres CACHE STRING "" FORCE)

project(MyProject LANGUAGES C CXX)

# C++
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Executable
add_executable(MyProject
    main.cpp
)

target_link_options(MyProject PRIVATE
    -static
    -static-libgcc
    -static-libstdc++
)

# Optional warnings
target_compile_options(MyProject PRIVATE
    -Wall
    -Wextra
    -Wpedantic
)