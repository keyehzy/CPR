FC = gfortran
#FC = g95

#FFLAGS = -O3 -fopenmp
#FFLAGS = -O3 -mcmodel=medium
#FFLAGS = -O0 -ggdb

#LFLAGS = -O3 -fopenmp
#LFLAGS = -O3 -mcmodel=medium
#LFLAGS = -O0 -ggdb

#LIBS = -lgomp /usr/lib/liblapack.a /usr/lib/libblas.a
#LIBS = 
LIBS = /lib64/liblapack.a /lib64/blas_LINUX.a

#DEBUG = -fsanitize=address

#OBJECTS = interface.o silicene2d.o tightb.o cherndet.o deter.o
OBJECTS = ogpf.o plot.o interface.o interpolation.o companion.o cpr.o

MODULES = ogpf.mod plot.mod interface.mod interpolation.mod companion.mod

DATA = 

.PHONY: clean

zzhand.dat: zigzaghand.exe
	./zigzaghand.exe > saida.dat

zigzaghand.exe: $(OBJECTS)
	$(FC) $(LFLAGS) $(OBJECTS) $(DEBUG) -o zigzaghand.exe $(LIBS)

%.mod : %.f90
	$(FC) $(FFLAGS) -c $<

%.o : %.f90
	$(FC) $(FFLAGS) -c $<

clean:
	rm -f $(OBJECTS) $(MODULES) $(DATA) $(FIGURES) zigzaghand.exe

help:
	@echo "Valid targets:"
	@echo "  zigzaghand.exe"
	@echo "  zigzaghand.o"
	@echo "  clean:  removes .o, .dat, .ps, and .exe files"
