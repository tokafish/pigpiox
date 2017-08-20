defmodule Pigpiox.GPIO.WatcherSupervisor do
  @moduledoc false

  use Supervisor

  @spec start_link(term) :: {:ok, pid} | {:error, term}
  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec start_watcher(integer, pid) :: {:ok, pid} | {:error, term}
  def start_watcher(gpio, pid) do
    Supervisor.start_child(__MODULE__, [gpio, pid])
  end

  @spec init(:ok) :: {:ok, {:supervisor.sup_flags, [:supervisor.child_spec]}}
  def init(:ok) do
    watcher_spec = Supervisor.child_spec(Pigpiox.GPIO.Watcher, start: {Pigpiox.GPIO.Watcher, :start_link, []})

    Supervisor.init([watcher_spec], strategy: :simple_one_for_one)
  end
end
