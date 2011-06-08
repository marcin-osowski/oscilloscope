# Device 0: XC3S100E - FPGA (Device ID: f5045093)
# Device 1: XCF02S - PROM (Device ID: 11c10093)
DEVICE_NUM=0

bit/oscilloscope.bit:
	cp work/oscilloscope.bit bit/

up: bit/oscilloscope.bit
	djtgcfg prog \
		-d Basys2 \
		-i $(DEVICE_NUM) \
		--file bit/oscilloscope.bit

