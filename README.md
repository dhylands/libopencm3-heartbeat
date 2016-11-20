LED blinker which uses libopencm3 and runs on the STM32F4 Discovery board.

This is basically a slightly edited variant of one of the libopencm3 examples
called [tick_blink](https://github.com/libopencm3/libopencm3-examples/tree/master/examples/stm32/f4/stm32f4-discovery/tick_blink),
but designed to be more standalone.

to build:
```
git clone https://github.com/libopencm3/libopencm3
cd libopencm3
make
cd ..
git clone https://github.com/dhylands/libopencm3-heartbeat heartbeat
cd heartbeat
make stlink
```

