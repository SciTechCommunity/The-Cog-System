defmodule Cog do
  @moduledoc """
  Documentation for Cog.
  """
  use Application

  @doc """
  Hello world.

  ## Examples

      iex> Cog.hello
      :world

  """
  def hello do
    :world
  end

  def start(_,_) do
    client = "MzM4MTcwNDE1Mjc0OTE3ODg4.DFRhRA.Y_5I451yC7sOb-hUi3LmmqINn38"
      |> Alchemy.Client.start
    Alchemy.Cogs.set_prefix("<@338170415274917888> ") # @Cog
    use Cog.{Commands, Admin, Vantage, Menu, Resource}
    spawn_monitor Vantage, :start, [%{}]
    Alchemy.Client.update_status "The Cog System"
    client
  end

  def restart_workers do
    pid = Process.whereis :brain
    Process.exit pid, :kill
    spawn_monitor Vantage, :start, [%{}]
  end

end
