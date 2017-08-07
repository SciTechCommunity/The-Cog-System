defmodule Cog do
  @moduledoc """
  Documentation for Cog.
  """
  use Application

  def main(args \\ []) do
    case args do
      [ token | [] ] ->
        key = File.read! "key"
        start token, [vantage: key]
        receive do
          something ->
            IO.inspect something
            main [token]
        end
      [] -> IO.puts "Please start with a token"
      _ -> IO.puts "Invalid command line args #{args}"
    end
  end

  def start(token, keys) do
    Process.register self(), :cog_engine
    client = Alchemy.Client.start token
    Alchemy.Cogs.set_prefix("<@338170415274917888> ") #@Cog
    use Cog.{Commands, Admin, Vantage, Menu, Resource}
    use Cog.{Experimental}
    spawn_monitor Vantage, :start, [keys[:vantage], %{}]
    spawn_monitor Subscriptions, :start, []
    Alchemy.Client.update_status "The Cog System"
    client
  end

  def restart_workers(keys) do
    pid = Process.whereis :brain
    Process.exit pid, :kill
    spawn_monitor Vantage, :start, [keys.vantage, %{}]
  end

end
