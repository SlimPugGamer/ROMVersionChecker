TARGET = romverchecker
TARGET_PACKED = romverchecker_pkd
R4D_TARGET = romverchecker_r4d
R4D_TARGET_PACKED = romverchecker_r4d_pkd
EE_OBJS += main.o
EE_BIN = $(TARGET).elf
EE_CFLAGS += -DNEWLIB_PORT_AWARE
EE_LIBS += -ldebug -lfileXio -lkernel -lelf-loader -lpatches
EE_INCS += -Isrc/include
EE_OBJS_R4D = main_r4d.o
CFLAGS_R4D = $(EE_CFLAGS) -DR4D $(EE_INCS)
EE_BIN_R4D = $(R4D_TARGET).elf
PACKED_BIN = $(TARGET_PACKED).elf
PACKED_BIN_R4D = $(R4D_TARGET_PACKED).elf

all: $(PACKED_BIN) $(PACKED_BIN_R4D)

clean:
	rm -f $(TARGET).elf $(EE_BIN_R4D) $(EE_OBJS) $(EE_OBJS_R4D) $(PACKED_BIN) $(PACKED_BIN_R4D)

%_r4d.o: %.c
	$(DIR_GUARD)
	$(EE_CC) $(CFLAGS_R4D) -c $< -o $@

$(EE_BIN_R4D): $(EE_OBJS_R4D)
	$(DIR_GUARD)
	$(EE_CC) -T$(EE_LINKFILE) $(CFLAGS_R4D) -o $@ $^ $(EE_LDFLAGS) $(EXTRA_LDFLAGS) $(EE_LIBS)

$(PACKED_BIN): $(TARGET).elf
	ps2-packer $< $@

$(PACKED_BIN_R4D): $(EE_BIN_R4D)
	ps2-packer $< $@

include $(PS2SDK)/samples/Makefile.pref
include $(PS2SDK)/samples/Makefile.eeglobal
