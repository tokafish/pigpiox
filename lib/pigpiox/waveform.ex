defmodule Pigpiox.Waveform do
  use Bitwise

  @moduledoc """
  Build and send waveforms with pigpiod.
  """

  @doc """
  Clears all waveforms and any data added.
  """
  @spec clear_all() :: :ok | {:error, atom}
  def clear_all()  do
    case Pigpiox.Socket.command(:waveform_clear_all) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  defmodule Pulse do
    @moduledoc false
    defstruct gpio_on: 0, gpio_off: 0, delay: 0
  end

  @typedoc """
  A pulse used in constructing a waveform. Specifies the GPIO that should be turned on, the GPIO that should be turned off,
  and the delay before the next pulse.

  At least one field is required to be set.
  """
  @type pulse :: %Pulse{}

  @doc """
  Adds a list of pulses to the current waveform

  Returns the new total number of pulses in the waveform or an error.
  """
  @spec add_generic(pulses :: list(pulse)) :: {:ok, non_neg_integer} | {:error, atom}
  def add_generic(pulses) do
    extents = Enum.flat_map pulses, fn pulse ->
      [mask(pulse.gpio_on), mask(pulse.gpio_off), pulse.delay]
    end
    Pigpiox.Socket.command(:waveform_add_generic, 0, 0, extents)
  end

  @doc """
  Creates a waveform based on previous calls to `add_...`

  Returns the id of the newly created waveform or an error
  """
  @spec create() :: {:ok, non_neg_integer} | {:error, atom}
  def create() do
    Pigpiox.Socket.command(:waveform_create)
  end

  @doc """
  Deletes a previously added waveform.
  """
  @spec delete(non_neg_integer) :: :ok | {:error, atom}
  def delete(wave_id) do
    case Pigpiox.Socket.command(:waveform_delete, wave_id) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Returns the id of the currently transmitted waveform.
  """
  @spec current() :: {:ok, non_neg_integer} | {:error, atom}
  def current() do
    Pigpiox.Socket.command(:waveform_current)
  end

  @doc """
  Returns whether or not a waveform is currently being transmitted.
  """
  @spec busy?() :: {:ok, boolean} | {:error, atom}
  def busy?() do
    case Pigpiox.Socket.command(:waveform_busy) do
      {:ok, 1} -> {:ok, true}
      {:ok, _} -> {:ok, false}
      error -> error
    end
  end

  @doc """
  Stops a waveform that is currently being transmitted.
  """
  @spec stop() :: :ok | {:error, atom}
  def stop() do
    case Pigpiox.Socket.command(:waveform_stop) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Sends a waveform once, by its id.

  Returns the number of DMA control blocks used in the waveform.
  """
  @spec send(non_neg_integer) :: {:ok, non_neg_integer} | {:error, atom}
  def send(wave_id) do
    Pigpiox.Socket.command(:waveform_transmit_once, wave_id)
  end

  @doc """
  Starts a repeating waveform, by its id.

  Returns the number of DMA control blocks used in the waveform.
  """
  @spec repeat(non_neg_integer) :: {:ok, non_neg_integer} | {:error, atom}
  def repeat(wave_id) do
    Pigpiox.Socket.command(:waveform_transmit_repeat, wave_id)
  end

  @doc """
  Returns the length in microseconds of the current waveform.
  """
  @spec get_micros() :: {:ok, non_neg_integer} | {:error, atom}
  def get_micros() do
    Pigpiox.Socket.command(:waveform_get_micros)
  end

  @doc """
  Returns the maximum possible size of a waveform in microseconds.
  """
  @spec get_max_micros() :: {:ok, non_neg_integer} | {:error, atom}
  def get_max_micros() do
    Pigpiox.Socket.command(:waveform_get_micros, 2)
  end

  @doc """
  Returns the length in pulses of the current waveform.
  """
  @spec get_pulses() :: {:ok, non_neg_integer} | {:error, atom}
  def get_pulses() do
    Pigpiox.Socket.command(:waveform_get_pulses)
  end

  @doc """
  Returns the maximum possible size of a waveform in pulses.
  """
  @spec get_max_pulses() :: {:ok, non_neg_integer} | {:error, atom}
  def get_max_pulses() do
    Pigpiox.Socket.command(:waveform_get_pulses, 2)
  end

  @doc """
  Returns the length in DMA control blocks of the current waveform.
  """
  @spec get_cbs() :: {:ok, non_neg_integer} | {:error, atom}
  def get_cbs() do
    Pigpiox.Socket.command(:waveform_get_cbs)
  end

  @doc """
  Returns the maximum possible size of a waveform in DMA control blocks.
  """
  @spec get_max_cbs() :: {:ok, non_neg_integer} | {:error, atom}
  def get_max_cbs() do
    Pigpiox.Socket.command(:waveform_get_cbs, 2)
  end

  @spec mask(non_neg_integer) :: non_neg_integer
  defp mask(0), do: 0
  defp mask(gpio) do
    1 <<< gpio
  end
end
