cmake_minimum_required(VERSION 3.25)

set(PROJECT_NAME "semantic_segmentation")
project(${PROJECT_NAME})

set(DATASET
	semantic_segmentation/dataset/file_pair.h
	semantic_segmentation/dataset/semantic_drone_dataset.cpp
	semantic_segmentation/dataset/semantic_drone_dataset.h
	semantic_segmentation/dataset/tiled_dataset.cpp
	semantic_segmentation/dataset/tiled_dataset.h
)

set(DRIVERS
	semantic_segmentation/drivers/main.cpp
	semantic_segmentation/drivers/test_vision.cpp
	semantic_segmentation/drivers/test_vision.h
	semantic_segmentation/drivers/testing.cpp
	semantic_segmentation/drivers/testing.h
	semantic_segmentation/drivers/trainer.cpp
	semantic_segmentation/drivers/trainer.h
)

set(GLOBALS
	semantic_segmentation/globals/globals.cpp
	semantic_segmentation/globals/globals.h
)

set(LEARNING
	semantic_segmentation/learning/optimizer.cpp
	semantic_segmentation/learning/optimizer.h
	semantic_segmentation/learning/trainer.cpp
	semantic_segmentation/learning/trainer.h
)

set(NETWORKS
	semantic_segmentation/networks/flatten.cpp
	semantic_segmentation/networks/flatten.h
	semantic_segmentation/networks/network.h
	semantic_segmentation/networks/network_d.h
)

set(VIEW
	semantic_segmentation/view/grid.cpp
	semantic_segmentation/view/grid.h
	semantic_segmentation/view/horizontal_layout.cpp
	semantic_segmentation/view/horizontal_layout.h
	semantic_segmentation/view/legend.cpp
	semantic_segmentation/view/legend.h
	semantic_segmentation/view/symbol.cpp
	semantic_segmentation/view/symbol.h
)

set(VISION
	semantic_segmentation/vision/bounding_box.cpp
	semantic_segmentation/vision/bounding_box.h
	semantic_segmentation/vision/convolutor.cpp
	semantic_segmentation/vision/convolutor.h
	semantic_segmentation/vision/image.cpp
	semantic_segmentation/vision/image.h
	semantic_segmentation/vision/reverse_convolutor.cpp
	semantic_segmentation/vision/reverse_convolutor.h
	semantic_segmentation/vision/tensor.cpp
	semantic_segmentation/vision/tensor.h
)

source_group(dataset FILES ${DATASET})
source_group(drivers FILES ${DRIVERS})
source_group(globals FILES ${GLOBALS})
source_group(learning FILES ${LEARNING})
source_group(networks FILES ${NETWORKS})
source_group(view FILES ${VIEW})
source_group(vision FILES ${VISION})

add_executable(${PROJECT_NAME}
	${DATASET}
	${DRIVERS}
	${GLOBALS}
	${LEARNING}
	${NETWORKS}
	${VIEW}
	${VISION}
)

include_directories(.)

# --- Compiler Flags ---
set(CMAKE_CXX_STANDARD 17)												# TODO: Do we need both?
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)
set(VS_STARTUP_PROJECT ${PROJECT_NAME})
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17")
set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD 17)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)
message(STATUS "Compiler Version: ${CMAKE_CXX_COMPILER_VERSION} standard ${CMAKE_CXX_STANDARD}")

if(MSVC)
	target_compile_options(${PROJECT_NAME} PRIVATE "/MP")	# parallel compilation
endif()

# --- Set Preprocessor Directives ---
# NOMINMAX
add_compile_definitions(NOMINMAX)	# same as '#define NOMINMAX'

# --- Libraries (excluding those in VCPKG packages) ---

# --- Torch ---
message(STATUS "/n----- Torch -----")

set(CMAKE_CUDA_ARCHITECTURES 75)# all)
find_package(Torch REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")

target_link_libraries(${PROJECT_NAME} PUBLIC
	"${TORCH_LIBRARIES}"
)

# Torch:
# The following code block is suggested to be used on Windows.
# According to https://github.com/pytorch/pytorch/issues/25457,
# the DLLs need to be copied to avoid memory errors.
if (MSVC)
	message(STATUS "--- :P d: :D :)BX8==; MSVC :) ---")

	file(GLOB TORCH_DLLS "${TORCH_INSTALL_PREFIX}/lib/*.dll")
	add_custom_command(
		TARGET ${PROJECT_NAME} 
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
		${TORCH_DLLS}
		$<TARGET_FILE_DIR:${PROJECT_NAME}>
	)
endif (MSVC)

# --- Libraries (VCPKG) ---

if (MSVC)
	message(STATUS "/nVCPKG packages will be automatically linked to visual studio/n")
else ()
	# --- For VCPKG packages ---
	#message(STATUS "call cmake with: cmake .. -DCMAKE_TOOLCHAIN_FILE=D:/code/libraries/vcpkg/scripts/buildsystems/vcpkg.cmake")

	# ----- BOOST -----

	message(STATUS "/n----- BOOST -----")
	set(Boost_USE_STATIC_LIBS		OFF)
	set(Boost_USE_MULTITHREADED		OFF)
	set(Boost_USE_STATIC_RUNTIME	OFF)

	find_package(Boost REQUIRED COMPONENTS
		filesystem 
		REQUIRED)

	target_link_libraries(${PROJECT_NAME} PUBLIC
		Boost::filesystem
	)

	message(STATUS "Include dirs ${Boost_INCLUDE_DIRS}")
	message(STATUS "Boost libraries ${Boost_LIBRARIES}")

	include_directories(${BOOST_INCLUDE_DIRS})

	target_include_directories(${PROJECT_NAME} PUBLIC
		${BOOST_INCLUDE_DIRS}
	)

endif (MSVC)
