#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>
#include <libopencm3/cm3/nvic.h>
#include <libopencm3/cm3/systick.h>

/* monotonically increasing number of milliseconds from reset
 * overflows every 49 days if you're wondering
 */
volatile uint32_t system_millis;

/* Called when systick fires */
void sys_tick_handler(void)
{
	system_millis++;
}

/* sleep for delay milliseconds */
static void msleep(uint32_t delay)
{
	uint32_t wake = system_millis + delay;
	while (wake > system_millis);
}

/* Set up a timer to create 1mS ticks. */
static void systick_setup(void)
{
	/* clock rate / 1000 to get 1mS interrupt rate */
	systick_set_reload(168000);
	systick_set_clocksource(STK_CSR_CLKSOURCE_AHB);
	systick_counter_enable();
	/* this done last */
	systick_interrupt_enable();
}

static void clock_setup(void) {
    rcc_clock_setup_hse_3v3(&rcc_hse_8mhz_3v3[RCC_CLOCK_3V3_168MHZ]);

    /* Enable GPIOD clock. */
    rcc_periph_clock_enable(RCC_GPIOD);
}

struct {
	uint32_t gpioport;
	uint16_t gpios;
} led[] = {
	{ GPIOD, GPIO12 },
	{ GPIOD, GPIO13 },
	{ GPIOD, GPIO14 },
	{ GPIOD, GPIO15 },
};
#define NUM_LEDS	4

static void gpio_setup(void)
{
	for (int i = 0; i < NUM_LEDS; i++) {
		gpio_mode_setup(led[i].gpioport, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, led[i].gpios);
	}
}

int main(void)
{
	clock_setup();
	systick_setup();
	gpio_setup();

	for (int i = 0; i < NUM_LEDS; i++) {
		gpio_clear(led[i].gpioport, led[i].gpios);
	}

	while (1) {
		for (int i = 0; i < 4; i++) {
			gpio_set(led[i].gpioport, led[i].gpios);
			msleep(100);
			gpio_clear(led[i].gpioport, led[i].gpios);
			msleep(100);
			gpio_set(led[i].gpioport, led[i].gpios);
			msleep(100);
			gpio_clear(led[i].gpioport, led[i].gpios);
			msleep(700);
		}
	}

	return 0;
}
