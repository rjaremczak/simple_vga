VHC = ghdl --std=02
SIM = gtkwave

all: clean analyze

analyze:
	@echo "analyzing designs..."
	@mkdir -p $(WORKDIR)
	$(VHC) -a --work=unisim --workdir=$(WORKDIR) -fexplicit \
	  --ieee=synopsys $(UNISRCS)
	$(VHC) -a --workdir=$(WORKDIR) -P$(WORKDIR) $(SRCS) $(TBS)

simulate: clean analyze
	@echo "simulating design:" $(TB)
	$(VHC) --elab-run --workdir=$(WORKDIR) -P$(WORKDIR) -fexplicit \
	  --ieee=synopsys -o $(WORKDIR)/$(ARCHNAME).bin $(ARCHNAME) \
	  --vcd=$(WORKDIR)/$(ARCHNAME).vcd --stop-time=$(STOPTIME)
	$(SIM) $(WORKDIR)/$(ARCHNAME).vcd

deploy: impl/simple_vga.runs/impl_1/mega65_r6.bit
	m65 -q $<

clean:
	@echo "cleaning design..."
	ghdl --remove --workdir=$(WORKDIR)
	rm -f $(WORKDIR)/*
	rm -rf $(WORKDIR)
