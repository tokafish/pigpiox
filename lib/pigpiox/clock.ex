defmodule Pigpiox.Clock do
  @moduledoc """
  Set clock with pigpiod.
  """
  
  @doc """
  Sets the fequency for the hardware CLK on a specific GPIO `pin`
  """
  @spec hardware_clk(pin :: integer, freq :: integer) :: :ok | {:error, atom}
  def hardware_clk(pin, freq) do
    case Pigpiox.Socket.command(:hardware_clk, pin, freq, []) do
      {:ok, _} -> :ok
      error -> error
    end
  end
end

