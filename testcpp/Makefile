TARGET   = test
OBJS     = test.o
FLAGS    = -I.. -g -O0 -Wall
INCLUDES =
LIBS     =
CC       = gcc
CXX      = clang++

all       : $(TARGET)

clean     :
	rm -f $(TARGET) $(OBJS)

$(TARGET) : $(OBJS)
	$(CXX) $(FLAGS) -o $@ $^ $(LIBS)

%.o       : %.cpp
	$(CXX) $(FLAGS) $(INCLUDES) -o $@ -c $<
