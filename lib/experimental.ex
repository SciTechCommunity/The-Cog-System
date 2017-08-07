defmodule Cog.Experimental.Helpers do
  use Alchemy.Cogs
  alias Alchemy.{Client}
  import Cog.Helpers

  def split_time(time) do
    time
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)
  end

  def set_time(message,sec) do
    {d,t} = {DateTime.utc_now |> DateTime.to_date |> Date.to_string, DateTime.utc_now |> DateTime.to_time |> Time.to_string |> String.split(".") |> hd}
    Task.start fn ->
      close message, 0
      Process.sleep sec*1000
      {:ok, alert} = Cogs.say """
      **<@#{message.author.id}>**,
      the timer you set at #{t} on #{d} has expired!
      ~~*(this message will self-destruct in 30 seconds)*~~
      """
      close alert, 30
    end
  end
end

defmodule Cog.Experimental do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers,Experimental.Helpers}

  Cogs.group("<@&341124683715837953>") # @Experimental

  Cogs.def up do
    Cogs.say "Ready for live experimentation!"
  end

  Cogs.def time do
    dt = DateTime.utc_now
    # days = ~s(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
    # day = Enum.at days, Date.day_of_week(d)
    Cogs.say "**Server Time:** #{inspect dt}"
  end

  Cogs.set_parser(:timer, &split_time/1)
  Cogs.def timer(s) do
    set_time message, s
    {:ok, sent} = Cogs.say "Timer set for #{s} seconds!"
    close sent, 3
  end
  Cogs.def timer(m,s) do
    set_time message, 60*m+s
    {:ok, sent} = Cogs.say "Timer set for #{m} minutes and #{s} seconds!"
    close sent, 3
  end
  Cogs.def timer(h,m,s) do
    set_time message, 3600*h+60*m+s
    {:ok, sent} = Cogs.say "Timer set for #{h} hours, #{m} minutes, and #{s} seconds!"
    close sent, 3
  end
end

