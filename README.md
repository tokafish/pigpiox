# Pigpiox

Pigpiox is a wrapper around pigpiod for the Raspberry Pi. For all of pigpio's features, check out its [documentation](http://abyz.co.uk/rpi/pigpio/index.html).

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

Usage instructions available on [hexdocs](https://hexdocs.pm/pigpiox/). In particular, look at the `Pigpiox.GPIO` module.

# Contributions

This library is still in a very early stage, and I'd appreciate any and all contributions. In particular, a short-term goal is getting feature parity with the [python](http://abyz.co.uk/rpi/pigpio/python.html) pigpiod client library.
