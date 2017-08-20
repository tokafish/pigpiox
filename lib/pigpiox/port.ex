defmodule Pigpiox.Port do
  require Logger
  use GenServer

  @moduledoc """
  Pigpiox.Port is a simple `GenServer` wrapping a port which runs pigpiod.

  It automatically restarts pigpiod on an unexpected exit.
  """

  @doc """
  Starts the pigpio daemon.
  """
  @spec start_link(list()) :: {:ok, pid} | {:error, term}
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, [], options)
  end

  @spec init(term) :: {:ok, port()}
  def init(_) do
    port = start_pigpiod()
    {:ok, port}
  end

  @spec start_pigpiod() :: port()
  defp start_pigpiod do
    _ = Logger.debug "Pigpiox.Port: starting pigpiod"
    path = System.find_executable("pigpiod")
    Port.open({:spawn_executable, path}, [:binary, :exit_status, args: ["-g", "-x", "-1"]])
  end

  def handle_info({_, {:exit_status, _}}, _) do
    _ = Logger.debug "Pigpiox.Port: pigpiod exited"
    port = start_pigpiod()
    {:noreply, port}
  end

  def handle_info(msg, state) do
    _ = Logger.debug "Pigpiox.Port: #{inspect msg}"
    {:noreply, state}
  end
end
