defmodule Cog.Helpers do
  use Alchemy.Cogs
  alias Alchemy.{Client}

  def close(msg, sec) do
    # You can't see this
    Task.start fn -> 
      Process.sleep sec*1000
      Client.delete_message msg
    end
  end
end

defm

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
    # Alchemy.Cogs.set_prefix("<@338170415274917888> ") #@Cog
    Alchemy.Cogs.set_prefix("<")
    use Cog.{Commands, Sudo, Vantage, Menu, Resource}
    use Cog.{Profiles, Experimental, Roles}
    use Cog.Events.{Welcome}#, Spam}
    # spawn_monitor Vantage, :start, [keys[:vantage], %{}]
    spawn_monitor Subscriptions, :start, [%{packt: [249991058132434945]}]
    # spawn_monitor Spam, :start, []
    spawn_monitor Profiles, :start, []
    client
  end

  def restart_workers(keys) do
    pid = Process.whereis :brain
    Process.exit pid, :kill
    spawn_monitor Vantage, :start, [keys.vantage, %{}]
  end



  def test(token) do
    spawn_monitor Cog, :main, [[token]]
    :observer.start
  end

end