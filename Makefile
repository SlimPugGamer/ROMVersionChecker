TARGET = romverchecker
TARGET_PACKED = romverchecker_pkd
R4D_TARGET = romverchecker_r4d
R4D_TARGET_PACKED = romverchecker_r4d_pkd
ARCADE_TARGET = romverchecker_arcade
ARCADE_TARGET_PACKED = romverchecker_arcade_pkd
EE_OBJS += main.o ps2dev9.o udptty_standalone.o
EE_OBJS_R4D = main_r4d.o ps2dev9.o udptty_standalone.o
EE_OBJS_ARCADE = main_arcade.o ps2dev9.o udptty_standalone.o IOPRP_FILEIO.o
EE_BIN = $(TARGET).elf
EE_BIN_R4D = $(R4D_TARGET).elf
EE_BIN_ARCADE = $(ARCADE_TARGET).elf
PACKED_BIN = $(TARGET_PACKED).elf
PACKED_BIN_R4D = $(R4D_TARGET_PACKED).elf
PACKED_BIN_ARCADE = $(ARCADE_TARGET_PACKED).elf
EE_CFLAGS += -DNEWLIB_PORT_AWARE
CFLAGS_R4D = $(EE_CFLAGS) -DR4D $(EE_INCS)
CFLAGS_ARCADE = $(EE_CFLAGS) -DARCADE $(EE_INCS)
EE_LIBS_COMMON = -ldebug -lfileXio -lkernel -lelf-loader -lpatches -lps2ips -lmc
EE_LIBS = $(EE_LIBS_COMMON) -lpad
EE_LIBS_ARCADE = $(EE_LIBS_COMMON) -lpadx
EE_INCS += -Iinclude -Imodules/iopcore/common -Imodules/network/common
EE_NEWLIB_NANO = 1
NEWLIB_NANO = 1
all: $(PACKED_BIN) $(PACKED_BIN_R4D) $(PACKED_BIN_ARCADE)

clean:
	rm -f $(TARGET).elf $(EE_BIN_R4D) $(EE_BIN_ARCADE) \
	      $(EE_OBJS) $(EE_OBJS_R4D) $(EE_OBJS_ARCADE) \
	      $(PACKED_BIN) $(PACKED_BIN_R4D) $(PACKED_BIN_ARCADE) \
	      IOPRP_FILEIO.c IOPRP_FILEIO.o

%_r4d.o: %.c
	$(DIR_GUARD)
	$(EE_CC) $(CFLAGS_R4D) -c $< -o $@

%_arcade.o: %.c
	$(DIR_GUARD)
	$(EE_CC) $(CFLAGS_ARCADE) -c $< -o $@

IOPRP_FILEIO.c: IOPRP_FILEIO.IMG
	$(PS2SDK)/bin/bin2c $< $@ ioprp

IOPRP_FILEIO.o: IOPRP_FILEIO.c
	$(EE_CC) $(EE_CFLAGS) -c $< -o $@

$(EE_ASM_DIR)ps2dev9.c: $(PS2SDK)/iop/irx/ps2dev9.irx | $(EE_ASM_DIR)
	/usr/local/ps2dev/ps2sdk/bin/bin2c $< $@ $(*F)_irx

$(EE_ASM_DIR)udptty_standalone.c: extra/udptty_standalone.irx | $(EE_ASM_DIR)
	/usr/local/ps2dev/ps2sdk/bin/bin2c $< $@ $(*F)_irx

$(EE_BIN_R4D): $(EE_OBJS_R4D)
	$(DIR_GUARD)
	$(EE_CC) -T$(EE_LINKFILE) $(CFLAGS_R4D) -o $@ $^ $(EE_LDFLAGS) $(EXTRA_LDFLAGS) $(EE_LIBS)

$(EE_BIN_ARCADE): $(EE_OBJS_ARCADE)
	$(DIR_GUARD)
	$(EE_CC) -T$(EE_LINKFILE) $(CFLAGS_ARCADE) -o $@ $^ $(EE_LDFLAGS) $(EXTRA_LDFLAGS) $(EE_LIBS_ARCADE)

$(PACKED_BIN): $(TARGET).elf
	ps2-packer $< $@

$(PACKED_BIN_R4D): $(EE_BIN_R4D)
	ps2-packer $< $@

$(PACKED_BIN_ARCADE): $(EE_BIN_ARCADE)
	ps2-packer $< $@

include $(PS2SDK)/samples/Makefile.pref
include $(PS2SDK)/samples/Makefile.eeglobal
