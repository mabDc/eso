cmake_minimum_required(VERSION 3.8)
project(quickjspp)

set(CMAKE_CXX_STANDARD 17)
#set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

if(CMAKE_COMPILER_IS_GNUCC)
    add_compile_options(-Wall -Wno-unused-parameter)
endif()

add_subdirectory(quickjs)
add_executable(qjs qjs.cpp)
target_link_libraries(qjs quickjs)

enable_testing()
add_subdirectory(test)
