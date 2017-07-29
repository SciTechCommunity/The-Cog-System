defmodule Cog do
  @moduledoc """
  Documentation for Cog.
  """
  use Application

  def main(args \\ []) do
    case args do
      [ token | [] ] ->
        start 0, token
      [] -> IO.puts "Please start with a token"
      _ -> IO.puts "Invalid command line args #{args}"
    end
  end

  def start(_,token) do
    Process.register self(), :cog_engine
    client = Alchemy.Client.start token
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
