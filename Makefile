
TARGET ?= heartbeat
FLASH_ADDR ?= 0x8000000

# Turn on increased build verbosity by defining BUILD_VERBOSE in your main
# Makefile or in your environment. You can also use V=1 on the make command
# line.

ifeq ("$(origin V)", "command line")
BUILD_VERBOSE=$(V)
endif
ifndef BUILD_VERBOSE
BUILD_VERBOSE = 0
endif
ifeq ($(BUILD_VERBOSE),0)
Q = @
else
Q =
endif
# Since this is a new feature, advertise it
ifeq ($(BUILD_VERBOSE),0)
$(info Use make V=1 or set BUILD_VERBOSE in your environment to increase build verbosity.)
endif

BUILD ?= build

RM = rm
ECHO = @echo

CROSS_COMPILE = arm-none-eabi-

AS = $(CROSS_COMPILE)as
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
SIZE = $(CROSS_COMPILE)size

LIBOPENCM3_DIR = libopencm3
LIBOPENCM3_LIBDIR = $(LIBOPENCM3_DIR)/lib
LIBOPENCM3_LIBNAME = opencm3_stm32f4

INC =  -I.
INC += -I$(LIBOPENCM3_DIR)/include

CFLAGS_CORTEX_M4 = -mthumb -mtune=cortex-m4 -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -fsingle-precision-constant -Wdouble-promotion -Werror

CFLAGS =  -DSTM32F4 $(INC)
CFLAGS += -Wextra -Wshadow -Wredundant-decls -Wall -Wmissing-prototypes -Wstrict-prototypes
CFLAGS += -ansi -std=gnu99 -nostdlib $(CFLAGS_CORTEX_M4) $(COPT)


#Debugging/Optimization
ifeq ($(DEBUG), 1)
CFLAGS += -g
COPT = -O0
else
COPT += -Os -DNDEBUG
endif

LDFLAGS = --static -nostartfiles -T stm32f4-discovery.ld -Wl,-Map=$(@:.elf=.map),--cref

LIBS = -L$(LIBOPENCM3_LIBDIR) -l$(LIBOPENCM3_LIBNAME)

OBJ = $(BUILD)/$(TARGET).o

all: $(BUILD)/$(TARGET).elf

define compile_c
$(ECHO) "CC $<"
$(Q)$(CC) $(CFLAGS) -c -MD -o $@ $<
@# The following fixes the dependency file.
@# See http://make.paulandlesley.org/autodep.html for details.
@cp $(@:.o=.d) $(@:.o=.P); \
  sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
      -e '/^$$/ d' -e 's/$$/ :/' < $(@:.o=.d) >> $(@:.o=.P); \
  rm -f $(@:.o=.d)
endef

$(OBJ): | $(BUILD)
$(BUILD):
	mkdir -p $@

$(BUILD)/%.o: %.c
	$(call compile_c)

pgm: $(BUILD)/$(TARGET).dfu
ifeq ($(USE_PYDFU),1)
	$(Q)./pydfu.py -u $^
else
	$(Q)dfu-util -a 0 -D $^ -s:leave
endif

$(BUILD)/$(TARGET).bin: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O binary $^ $@

$(BUILD)/$(TARGET).dfu: $(BUILD)/$(TARGET).bin
	$(Q)./dfu.py -b $(FLASH_ADDR):$^ $@

$(BUILD)/$(TARGET).elf: $(OBJ)
	$(ECHO) "LINK $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)
	$(Q)$(SIZE) $@

stlink: $(BUILD)/$(TARGET).bin
	$(Q)st-flash --reset write $^ $(FLASH_ADDR)

uart: $(BUILD)/$(TARGET).bin
	$(Q)./stm32loader.py -p /dev/ttyUSB0 -evw $^

# Unprotect does a MASS erase, so it shouldn't try to flash as well.
# And on the STM32F103, the ACK never gets received
uart-unprotect:
	$(Q)./stm32loader.py -p /dev/ttyUSB0 -uV

clean:
	$(RM) -rf $(BUILD)
.PHONY: clean

-include $(OBJ:.o=.P)

