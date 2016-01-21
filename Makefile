CC  ?=gcc
CXX ?=g++
INCLUDES:=$(shell pkg-config --cflags sdl2 glew glfw3 ) -I.
CPPFLAGS += -Wall -Wextra -g -ggdb -O3 -pthread -fPIC -dpic
OPTFLAGS += -fomit-frame-pointer -ffast-math -I. -fPIC -DPIC -fno-math-errno \
						-freciprocal-math -fassociative-math -fno-trapping-math -fno-signed-zeros \
						-ftree-vectorize  -ftree-vectorize -mrecip=vec-div,sqrt,vec-sqrt \
						-pthread -ftls-model=initial-exec\
						-ffinite-math-only -mcx16 -mfpmath=sse

CFLAGS += -std=gnu11 $(OPTFLAGS) $(CPPFLAGS)
CXXFLAGS += -std=gnu++14 $(OPTFLAGS) $(CPPFLAGS) -Wno-c++11-narrowing -lstdc++ $(shell pkg-config --cflags Qt5Core Qt5Gui)
LDFLAGS:=$(shell pkg-config --libs --cflags sdl2 glew glfw3 Qt5Core Qt5Gui)  -L/lib/x86_64-linux-gnu -lm -lstdc++ -lportaudio $(shell pkg-config --libs Qt5Core Qt5Gui)  $(shell pkg-config --libs --cflags libavutil libavdevice libavformat libavcodec libavfilter libswresample )

EXTRA_OBJS:= 

EXE:=
EXE += $(patsubst %.c,%,$(wildcard *_test.c))
EXE += $(patsubst %.cpp,%,$(wildcard *_test.cpp))

LIB += $(patsubst %.c,%.so,$(wildcard *_lib.c))
LIB += $(patsubst %.cpp,%.so,$(wildcard *_lib.cpp))

.SECONDARY:

all: dirs  $(addprefix bin/, $(EXE)) $(addprefix lib/, $(LIB))

dirs:
	mkdir -p bin
	mkdir -p obj
	mkdir -p lib


bin/%: obj/%.o $(EXTRA_OBJS)
	$(CC) $(CPPFLAGS) $(EXTRA_OBJS) $< $(LDFLAGS) -o $@

lib/%.so: obj/%.o $(EXTRA_OBJS)
	$(CXX) $(CPPFLAGS) $(EXTRA_OBJS) -shared $< $(LDFLAGS) -o $@

obj/%.o: %.c
	$(CC) $(CFLAGS) $< $(INCLUDES) -c -o $@

obj/%.o: %.cpp
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) -c -o $@

obj/murmur_test.o: obj/MurmurHash3.o
install:
	install bin/le        ~/.local/bin
	install bin/tmuxstats ~/.local/bin
clean:
	rm -f obj/* bin/* tags


