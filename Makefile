# Directories
RTL_DIR   := rtl
TB_DIR    := tb
OUT_DIR   := sim

# Tools
IVL       := iverilog
IVLFLAGS  := -g2012 -Wall
VVP       := vvp
GTKWAVE   := gtkwave

# Files
TOP_TB    := registerfile_tb
OUT_BIN   := $(OUT_DIR)/sim.out
VCD_FILE  := $(OUT_DIR)/waveform.vcd

# Sources
RTL_SRCS  := $(wildcard $(RTL_DIR)/*.sv)
TB_SRCS   := $(wildcard $(TB_DIR)/*.sv)

.PHONY: all compile sim wave clean

all: sim

compile: $(OUT_BIN)

$(OUT_BIN): $(RTL_SRCS) $(TB_SRCS)
	@mkdir -p $(OUT_DIR)
	$(IVL) $(IVLFLAGS) -o $(OUT_BIN) -s $(TOP_TB) $(RTL_SRCS) $(TB_SRCS)

sim: $(OUT_BIN)
	cd $(OUT_DIR) && $(VVP) $(notdir $(OUT_BIN))

wave:
	$(GTKWAVE) $(VCD_FILE) &

clean:
	rm -rf $(OUT_DIR)/*