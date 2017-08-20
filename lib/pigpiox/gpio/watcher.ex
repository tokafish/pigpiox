defmodule Pigpiox.GPIO.Watcher do
  @moduledoc false

  use GenServer
  use Bitwise
  require Logger

  defmodule State do
    @moduledoc false

    defstruct gpio: nil, level: nil, handle: nil, owner: nil
  end

  def start_link(gpio, pid) do
    GenServer.start_link(__MODULE__, {gpio, pid})
  end

  @spec init({pin :: non_neg_integer, owner :: pid}) :: {:ok, %State{}} | {:stop, atom}
  def init({gpio, pid}) do
    with {:ok, handle} <- Pigpiox.Socket.command(:notify_open),
         _port         <- open_port(handle),
         {:ok, _}      <- Pigpiox.Socket.command(:notify_begin, handle, mask(gpio)),
         {:ok, level}  <- Pigpiox.GPIO.read(gpio)
    do
      state = %State{gpio: gpio, level: level, handle: handle, owner: pid}
      notify_level_change!(state)
      {:ok, state}
    else
      {:error, error} -> {:stop, error}
      _ -> {:stop, :error}
    end
  end

  @spec handle_info(msg :: tuple, %State{}) :: {:noreply, %State{}} | {:stop, :port_exited, %State{}}
  def handle_info({_, {:data, event}}, state) do
    <<_seqno :: native-unsigned-integer-size(16),
      _flags :: native-unsigned-integer-size(16),
      _tick :: native-unsigned-integer-size(32),
      gpio_bits :: native-unsigned-integer-size(32)>> = event

    level = if (gpio_bits &&& mask(state.gpio)) > 0 do
      1
    else
      0
    end

    if level != state.level do
      updated_state = %{state | level: level}
      notify_level_change!(updated_state)
      {:noreply, updated_state}
    else
      {:noreply, state}
    end
  end

  def handle_info({_, {:exit_status, _}}, state) do
    _ = Logger.debug "GPIO.Watcher: port died"
    {:stop, :port_exited, state}
  end

  def terminate(_reason, state) do
    Pigpiox.Socket.command(:notify_close, state.handle)
  end

  @spec open_port(non_neg_integer) :: port()
  defp open_port(handle) do
    path = System.find_executable("dd")
    Port.open({:spawn_executable, path}, [:binary, :exit_status, args: ["if=/dev/pigpio#{handle}", "bs=12"]])
  end

  @spec mask(non_neg_integer) :: non_neg_integer
  defp mask(gpio) do
    1 <<< gpio
  end

  @spec mask(%State{}) :: no_return
  defp notify_level_change!(state) do
    send state.owner, {:gpio_leveL_change, state.gpio, state.level}
  end
end
