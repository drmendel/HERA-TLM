cmake_minimum_required(VERSION 3.12)

# Project name and version
project(HERA_TLM VERSION 1.0)

# Define the name of the executable in a variable
set(EXECUTABLE_NAME "cspice_websocket_server")

# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Use ccache if installed for faster builds
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
    set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
endif()

set(CMAKE_BUILD_TYPE Debug)  # Disable optimization for dev !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Define the path to external libraries
set(CSPICE_DIR ${CMAKE_SOURCE_DIR}/ext/cspice)

# Include directories for CSPICE and other necessary headers
include_directories(
    ${CSPICE_DIR}/include
    ${CMAKE_SOURCE_DIR}/inc
)

# Find the CSPICE library
set(CSPICE_LIB ${CSPICE_DIR}/lib/cspice.a)

# Check if the CSPICE library exists
if(NOT EXISTS ${CSPICE_LIB})
    message(FATAL_ERROR "CSPICE library not found at ${CSPICE_LIB}")
endif()

# Collect all the source files
file(GLOB SOURCES
    src/*.cpp
)

# Add executable and link libraries
add_executable(${EXECUTABLE_NAME} ${SOURCES})

# Link libraries
target_link_libraries(${EXECUTABLE_NAME}
    ${CSPICE_LIB}  # Link the CSPICE library
)

# Optional: If you want to install your program
install(TARGETS ${EXECUTABLE_NAME} DESTINATION bin)
