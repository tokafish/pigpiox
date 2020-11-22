defmodule Pigpiox.Pwm do
  use Bitwise

  defdelegate set_pwm_dutycycle(pin, level), to: __MODULE__, as: :gpio_pwm

  @moduledoc """
  Build and send waveforms with pigpiod.
  """

  @doc """
  Sets the current dutycycle and fequency for the hardware PWM on a specific GPIO `pin`. Max value for `level` is `1_000_000`.
  """
  @spec hardware_pwm(pin :: integer, freq :: integer, level :: integer) :: :ok | {:error, atom}
  def hardware_pwm(pin, freq, level) when level in 0..1_000_000 do
    case Pigpiox.Socket.command(:hardware_pwm, pin, freq, [level]) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Sets up a specific pin as a software PWM and sets the current dutycycle. Max value for `level` is `255`.
  """
  @spec gpio_pwm(pin :: integer, level :: integer) :: :ok | {:error, atom}
  def gpio_pwm(pin, level) when level in 0..255 do
    case Pigpiox.Socket.command(:gpio_PWM, pin, level) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Get the current dutycycle for a specific PWM GPIO `pin`
  """
  @spec get_pwm_dutycycle(pin :: integer) :: {:ok, integer} | {:error, atom}
  def get_pwm_dutycycle(pin) do
    case Pigpiox.Socket.command(:get_PWM_dutycycle, pin) do
      {:ok, level} -> {:ok, level}
      error -> error
    end
  end

  @doc """
  Set the current frequency for a specific PWM GPIO `pin`
  """
  @spec set_pwm_frequency(pin :: integer, freq :: integer) :: :ok | {:error, atom}
  def set_pwm_frequency(pin, freq) do
    case Pigpiox.Socket.command(:set_PWM_frequency, pin, freq) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Get the current frequency for a specific PWM GPIO `pin`
  """
  @spec get_pwm_frequency(pin :: integer) :: {:ok, integer} | {:error, atom}
  def get_pwm_frequency(pin) do
    case Pigpiox.Socket.command(:get_PWM_frequency, pin) do
      {:ok, freq} -> {:ok, freq}
      error -> error
    end
  end
end
