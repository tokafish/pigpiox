# Pigpiox

Pigpiox is a wrapper around pigpiod for the Raspberry Pi. For all of pigpio's features, check out its [documentation](http://abyz.me.uk/rpi/pigpio/).


# Requirements

To use Pigpiox, pigpiod must be included in your firmware. Currently, this is included by default on `nerves_system_rpi0`, but not on other Pi systems.

If you'd like to use Pigpiox on one of those systems, customize the nerves system you're interested in, and add `BR2_PACKAGE_PIGPIO=y` to its `nerves_defconfig`.

# Installation

In your firmware's `mix.exs`, add `pigpiox` to your deps for your system target:

```elixir
def deps(target) do
  [ system(target),
    {:pigpiox, "~> 0.1"}
  ]
```

# Usage

Adding pigpiox as a dependency to your system will automatically launch the pigpio daemon and open a socket to communicate with it. To interact with pigpiod, Pigpiox provides various modules exposing different areas of functionality.

All documentation available on [hexdocs](https://hexdocs.pm/pigpiox/).

## GPIO

### Basic functionality

The `Pigpiox.GPIO` provides basic GPIO functionality. Here's an example of reading and writing a GPIO:

```elixir
gpio = 17

Pigpiox.GPIO.set_mode(gpio, :input)
{:ok, level} = Pigpiox.GPIO.read(gpio)

Pigpiox.GPIO.set_mode(gpio, :output)
Pigpiox.GPIO.write(gpio, 1)
```

### Watching a GPIO

When reading a GPIO, often it's useful to know immediately when its level changes, instead of having to constantly poll it. Here's an example:

```elixir
{:ok, pid} = Pigpiox.GPIO.watch(gpio)
```

After setting up a watch on a GPIO pin, the calling process will receive messages of the format `{:gpio_leveL_change, gpio, level}` as its level change.

## Waveforms

The `Pigpiox.Waveform` module provides functions that allow you to create and send waveforms on the Raspberry Pi. Here's an example of pulsing a GPIO on and off every 500ms:

```elixir
pulses = [
  %Pigpiox.Waveform.Pulse{gpio_on: gpio, delay: 500000},
  %Pigpiox.Waveform.Pulse{gpio_off: gpio, delay: 500000}
]

Pigpiox.Waveform.add_generic(pulses)

{:ok, wave_id} = Pigpiox.Waveform.create()

Pigpiox.GPIO.set_mode(gpio, :output)

Pigpiox.Waveform.repeat(wave_id)
```

## Waveform chains

You can compose more complex waveform by chaining them.
For example, pulsing a GPIO on and off every 500 ms for 10 times and then 50 ms for 100 times and this forever. Chain can be nested.

```elixir
pulses_500 = [
  %Pigpiox.Waveform.Pulse{gpio_on: gpio, delay: 500_000},
  %Pigpiox.Waveform.Pulse{gpio_off: gpio, delay: 500_000}
]

Pigpiox.Waveform.add_generic(pulses_500)

{:ok, wave_500} = Pigpiox.Waveform.create()

pulses_50 = [
  %Pigpiox.Waveform.Pulse{gpio_on: gpio, delay: 50_000},
  %Pigpiox.Waveform.Pulse{gpio_off: gpio, delay: 50_000}
]

Pigpiox.Waveform.add_generic(pulses_50)

{:ok, wave_50} = Pigpiox.Waveform.create()

Pigpiox.GPIO.set_mode(gpio, :output)

Pigpiox.Waveform.chain(%Pigpiox.Waveform.ChainElement{
  content: [
    %Pigpiox.Waveform.ChainElement{
      content: [wave_500],
      repeat: 10
    },
    %Pigpiox.Waveform.ChainElement{
      content: [wave_50],
      repeat: 100
    }
  ],
  repeat: :forever
})

Pigpiox.Waveform.repeat(wave_id)
```

## Clock

The `Pigpiox.Clock` module provides functions that allow you to set a clock on reserved pin.

```elixir
Pigpiox.Clock.hardware_clk(gpio, 2_500_000)
```

## Pulse-width modulation (PWM)

The [`Pigpiox.Pwm` module](https://hexdocs.pm/pigpiox/Pigpiox.Pwm.html#content) provides functions that allow you to build and send waveforms with pigpiod.
According to [Raspberry Pi's GPIO usage documentation](https://www.raspberrypi.org/documentation/usage/gpio/), here are the pins PWM is avaliable on:

- Software PWM: all pins
- Hardware PWM: GPIO12, GPIO13, GPIO18, GPIO19

### Software PWM

Max value for `level` is `255`. Here's an example of changing the brightness of an LED using software PWM.

```elixir
gpio = 12
Pigpiox.Pwm.gpio_pwm(gpio, 255) # 100%
Pigpiox.Pwm.gpio_pwm(gpio, 127) # 50%
Pigpiox.Pwm.gpio_pwm(gpio, 25)  # 10%
Pigpiox.Pwm.gpio_pwm(gpio, 2)   # 1%
```

### Hardware PWM

Max value for `level` is `1_000_000`. Here's an example of changing the brightness of an LED using hardware PWM.

```elixir
gpio = 12
frequency = 800
Pigpiox.Pwm.hardware_pwm(gpio, frequency, 1_000_000) # 100%
Pigpiox.Pwm.hardware_pwm(gpio, frequency, 500_000)   # 50%
Pigpiox.Pwm.hardware_pwm(gpio, frequency, 100_000)   # 10%
Pigpiox.Pwm.hardware_pwm(gpio, frequency, 10_000)    # 1%
```

# Contributions

This library is still in a very early stage, and I'd appreciate any and all contributions. In particular, a short-term goal is getting feature parity with the [python](http://abyz.me.uk/rpi/pigpio/python.html) pigpiod client library.
