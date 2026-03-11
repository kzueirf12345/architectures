.PHONY: all build start clean clean_out clean_vcd \


PROJECT_NAME = alu_register

SRC_DIR = ./src

SOURCES = alu.v alu_tb.v

SOURCES_REL_PATH = $(SOURCES:%=$(SRC_DIR)/%)

all: build start

start:
	gtkwave dump.vcd

build: $(PROJECT_NAME).out
	./$(PROJECT_NAME).out


$(PROJECT_NAME).out: $(SOURCES_REL_PATH)
	iverilog $(SOURCES_REL_PATH) -o $(PROJECT_NAME).out

clean: clean_out clean_vcd

clean_out:
	rm -rf ./*.out

clean_vcd:
	rm -rf ./*.vcd