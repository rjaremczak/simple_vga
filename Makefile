VHC = ghdl
SIM = gtkwave

all: clean analyze

analyze:
	@echo "analyzing designs..."
	@mkdir -p $(WORKDIR)
	$(VHC) -a --work=unisim --workdir=$(WORKDIR) -fexplicit  $(VHDLSTD) \
	  --ieee=synopsys $(UNISRCS)
	$(VHC) -a --workdir=$(WORKDIR) -P$(WORKDIR)  $(VHDLSTD) $(SRCS) $(TBS)

simulate: clean analyze
	@echo "simulating design:" $(TB)
	$(VHC) --elab-run --workdir=$(WORKDIR) -P$(WORKDIR) $(VHDLSTD) -fexplicit \
	  --ieee=synopsys -o $(WORKDIR)/$(ARCHNAME).bin $(ARCHNAME) \
	  --vcd=$(WORKDIR)/$(ARCHNAME).vcd --stop-time=$(STOPTIME)
	$(SIM) $(WORKDIR)/$(ARCHNAME).vcd

clean:
	@echo "cleaning design..."
	ghdl --remove --workdir=$(WORKDIR)
	rm -f $(WORKDIR)/*
	rm -rf $(WORKDIR)
