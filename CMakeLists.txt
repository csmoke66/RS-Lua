cmake_minimum_required(VERSION 3.20)

# Cross-compile for Windows
set(CMAKE_SYSTEM_NAME Windows)

# Toolchain
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++ CACHE STRING "" FORCE)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres CACHE STRING "" FORCE)

project(AdminPatcher LANGUAGES C CXX)

# C++
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Executable
add_executable(AdminPatcher
    main.cpp
)

target_link_options(AdminPatcher PRIVATE
    -s
    -static
    -static-libgcc
    -static-libstdc++
)

# Optional warnings
target_compile_options(AdminPatcher PRIVATE
    -Wall
    -Wextra
    -Wpedantic
)

add_custom_command(TARGET AdminPatcher POST_BUILD
    COMMAND ${CMAKE_STRIP} $<TARGET_FILE:AdminPatcher>
)