LED blinker which uses libopencm3 and runs on the STM32F4 Discovery board.

This is basically a slightly edited variant of one of the libopencm3 examples
called [tick_blink](https://github.com/libopencm3/libopencm3-examples/tree/master/examples/stm32/f4/stm32f4-discovery/tick_blink),
but the Makefile is designed to be more standalone.

### Prerequisites

- arm-none-eabi toolchain. Tested with the 4.9.3 version from [launchpad](https://launchpad.net/gcc-arm-embedded)
- [stlink](https://github.com/texane/stlink)
- python 2.7 (libopencm3's build uses this)

### Build

```
git clone https://github.com/dhylands/libopencm3-heartbeat heartbeat
cd heartbeat
make
```

### Flash

To flash using the STM32F4 builtin discovery STLINK flasher:
```
make stlink
```
