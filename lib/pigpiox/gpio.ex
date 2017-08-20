defmodule Pigpiox.GPIO do
	@gpio_modes_map %{
		input:  0,
		output: 1,
		alt0:   4,
		alt1:   5,
		alt2:   6,
		alt3:   7,
		alt4:   3,
		alt5:   2
	}
	@gpio_modes Map.keys(@gpio_modes_map)
	@inverted_gpio_modes_map for {key, val} <- @gpio_modes_map, into: %{}, do: {val, key}

  @moduledoc """
  This module exposes pigpiod's basic GPIO functionality.
  """

  @typedoc """
  A mode that a GPIO pin can be in. Returned by `get_mode/1` and passed to `set_mode/2`.
  """
  @type mode :: :input | :output | :alt0 | :alt1 | :alt2 | :alt3 | :alt4 | :alt5

  @typedoc """
  The state of a GPIO pin - 0 for low, 1 for high.
  """
  @type level :: 0 | 1

  @doc """
  Sets a mode for a specific GPIO `pin`. `pin` must be a valid GPIO pin number for the device, with some exceptions.
  See pigpio's [documentation](http://abyz.co.uk/rpi/pigpio/index.html) for more details.

  `mode` can be any of `t:mode/0`.
  """
  @spec set_mode(pin :: integer, mode) :: :ok | {:error, atom}
	def set_mode(pin, mode) when mode in @gpio_modes do
    case Pigpiox.Socket.command(:set_mode, pin, @gpio_modes_map[mode]) do
      {:ok, _} -> :ok
      error -> error
    end
	end

  @doc """
  Returns the current mode for a specific GPIO `pin`
  """
  @spec get_mode(pin :: integer) :: {:ok, mode | :unknown} | {:error, atom}
	def get_mode(pin) do
    case Pigpiox.Socket.command(:get_mode, pin) do
      {:ok, result} -> {:ok, @inverted_gpio_modes_map[result] || :unknown}
      error -> error
    end
	end

  @doc """
  Returns the current level for a specific GPIO `pin`
  """
  @spec read(pin :: integer) :: {:ok, level} | {:error, atom}
  def read(pin) do
    Pigpiox.Socket.command(:gpio_read, pin)
  end

  @doc """
  Sets the current level for a specific GPIO `pin`
  """
  @spec write(pin :: integer, level) :: :ok | {:error, atom}
  def write(pin, level) when level in [0, 1] do
    case Pigpiox.Socket.command(:gpio_write, pin, level) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Starts a watcher to monitor the level of a specific GPIO `pin`

  The calling process will receive a message with the current level of the pin,
  as well as a message every time the level of that pin changes.

  The message will be of the format:

     `{:gpio_leveL_change, gpio, level}`
  """
  @spec watch(integer) :: {:ok, pid} | {:error, atom}
  def watch(pin) do
    Pigpiox.GPIO.WatcherSupervisor.start_watcher(pin, self())
  end

  @doc """
  Returns the current servo pulsewidth for a specific GPIO `pin`
  """
  @spec get_servo_pulsewidth(pin :: integer) :: {:ok, non_neg_integer} | {:error, atom}
  def get_servo_pulsewidth(pin) do
    Pigpiox.Socket.command(:get_servo_pulsewidth, pin)
  end

  @doc """
  Sets the servo pulsewidth for a specific GPIO `pin`.

  The pulsewidths supported by servos varies and should probably
  be determined by experiment. A value of 1500 should always be
  safe and represents the mid-point of rotation.

  A pulsewidth of 0 will stop the servo.

  You can DAMAGE a servo if you command it to move beyond its
  limits.
  """
  @spec set_servo_pulsewidth(pin :: integer, width :: non_neg_integer) :: :ok | {:error, atom}
  def set_servo_pulsewidth(pin, width) when width >= 0 and width <= 2500 do
    case Pigpiox.Socket.command(:set_servo_pulsewidth, pin, width) do
      {:ok, _} -> :ok
      error -> error
    end
  end
end
