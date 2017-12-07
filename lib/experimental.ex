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

  Cogs.group("@&341124683715837953>") # @Experimental

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

  Cogs.def profile do
    Cogs.say "Live coding in progress!"
  end
  Cogs.def profile(member) do
    IO.inspect member
    Cogs.say "Live coding in progress!"
  end

  Cogs.def credits do
    IO.inspect message.author
    Cogs.say "Live coding in progess!"
  end
end


defmodule Profile do
  defstruct tokens: 0, challenge: "no challenge specified", nick: "", color: 16777215, motto: "no motto specified", info: "no info specified", zone: "UTC", url: "https://github.com/TumblrCommunity/The-Cog-System", image: "https://cdn.discordapp.com/embed/avatars/0.png"
end

defmodule Cog.Profiles.Helpers do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Embed,Client}
  import Cog.Helpers

  def display_profile(message, user) do
    send :profiles, {:get, user.id |> String.to_integer, self()}
    receive do
      nil ->
        send :profiles, {:update, user.id |> String.to_integer, {%Profile{}, &(&1)}, self()}
        receive do
          :ok ->
            display_profile message, user
          e ->
            IO.inspect e
        end 
      # https://cdn.discordapp.com/embed/avatars/0.png
      # https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Clock_simple.svg/1024px-Clock_simple.svg.png
      profile ->
        %Profile{tokens: tokens, challenge: challenge, nick: nick, color: color, motto: motto, info: info, zone: zone, url: url, image: image} = profile
        %Alchemy.User{discriminator: id, username: name} = user
        avatar_url = Alchemy.User.avatar_url user
        nick = if nick != "", do: nick, else: name <> " ~~no user nickname set~~"
        
        embed = %Embed{
          title: motto,
          description: info,
          url: url,
          color: color
        } |> Embed.timestamp(DateTime.utc_now)
        |> Embed.footer(text: "#{zone} (no user timezone set)", icon_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Clock_simple.svg/1024px-Clock_simple.svg.png")
        |> Embed.author(name: "#{nick}'s Profile:", url: url, icon_url: avatar_url)        
        |> Embed.field(":moneybag: Tokens", "#{tokens} **CST**", inline: true)
        |> Embed.field(":dizzy_face: Current Challenge", challenge, inline: true)
        |> Embed.send("<@&345314788642914325> <@#{user.id}>")
    end
  end
end

defmodule Cog.Profiles do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers,Profiles.Helpers}

  Cogs.group("@&345314788642914325>") # @Profiles

  Cogs.def tokens do
    close message, 1
    send :profiles, {:get, message.author.id |> String.to_integer, self()}
    receive do
      profile ->
        {:ok, sent} = Cogs.say "#{profile.nick}, you currently have #{profile.tokens} **CST**!"
        close sent, 10
    end
  end
  
  Cogs.set_parser(:show, fn x -> IO.inspect x; [x] end)
  Cogs.def show(<<>>) do
    close message, 1
    display_profile message, message.author
  end
  Cogs.def show(ids) do
    close message, 1
    for user <- message.mentions, not user.bot do
      display_profile message, user
    end
  end

  Cogs.def award(user, points) do
    close message, 3

    id = user
      |> String.to_charlist
      |> Enum.reduce(0, fn
        x, acc ->
          cond do
            x in ?0..?9 -> 10*acc + (x-?0)
            true -> acc
          end
        end)
    points = String.to_integer points

    send :profiles, {:update, id, {%Profile{tokens: points}, &(%{&1 | tokens: &1.tokens + points})}, self()}
    receive do
      :ok ->
        {:ok, sent} = Cogs.say "#{user} has been awarded #{points} **CST**"
        close sent, 10
      message ->
        IO.inspect message
    end
  end
    
end


defmodule Profiles do
  import Cog.{Helpers,Profiles.Helpers}
  
  def start do
    {profiles, _bindings} = Code.eval_file "profiles"
    start profiles
  end
  def start(data) do
    Process.register self(), :profiles
    # spawn_link &dump/0
    listen data
  end

  def dump do
    Process.sleep 120*1000
    send :profiles, {:dump, self()}
    receive do
      _ ->
        dump
    end
  end

  def listen(data) do
    receive do
      {:dump, sender} ->
        # spawn_link fn -> File.write! "profiles", (inspect data) end
        send sender, data
        data
      {:get, id, sender} ->
        send sender, data[id]
        data
      {:update, id, {profile, fun}, sender} ->
        send sender, :ok
        Map.update data, id, profile, fun
      {:take, id, sender} ->
        {profile, data} = Map.pop data, id
        send sender, profile
        data
    end |> listen
  end
end