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


defmodule Cog.Commands.Helpers do
  def diff(time1, time2, unit \\ :milliseconds) do
    from = fn
      %NaiveDateTime{} = x -> x
      x -> NaiveDateTime.from_iso8601!(x)
    end
    {time1, time2} = {from.(time1), from.(time2)}
    NaiveDateTime.diff(time1, time2, unit)
  end

  def extract_topic(topic), do: {topic["Text"], topic["FirstUrl"]}
end

defmodule Cog.Commands do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers,Commands.Helpers}


  Cogs.def help do
    Cogs.say """
    If you want to access the full menu, please run `@Cog @Menu open`.
    If you are looking for basic commands, try `@Cog commands`.
    For more details on system usage, refer to `@Cog usage`.
    """
  end

  Cogs.def commands do
    Cogs.say "#{inspect Cogs.all_commands}"
  end

  Cogs.def usage do
    Cogs.say "Live coding in progress..."
  end

  Cogs.def author do
    Cogs.say "<@249991058132434945>\nLive coding in progress..."
  end

  Cogs.def source do
    Cogs.say "The Cog system is currently a closed source project. For more information, contact your local administrator or the system's creator."
  end

  Cogs.def ping do
    # message is an implicit parameter to commands
    old = message.timestamp

    # send pong
    {:ok, message} = Cogs.say "pong"

    # diff times and update
    time = diff(message.timestamp, old)
    Client.edit_message(message, message.content <> " @ #{time} ms")
  end

  Cogs.set_parser(:duckduck, fn rest -> [rest] end)
  Cogs.def duckduck(term) do
    IO.inspect term

    # Convert term to percentage trash
    # send it down the tube
    # wait
    # pray...
    resp = term
      |> URI.encode(fn _ -> false end)
      |> (&("http://api.duckduckgo.com/?q=#{&1}&format=json")).()
      |> HTTPoison.get!
      |> Map.get(:body)
      |> Poison.decode!
    
    # Extract what you can
    # make stuff up where you can't
    abstract = resp["AbstractText"]
    {text, link} = case abstract do
      "" -> extract_topic(resp["RelatedTopics"] |> hd)
      _ -> {resp["AbstractText"], resp["AbstractURL"]}
    end
    head = resp["Heading"]

    # Send search data to discord
    Cogs.say """
    ***#{head}***\n
    #{text}\n
    **Read more:** #{link}
    """
  end

  # Cogs.set_parser(:latex, fn rest -> [rest] end)
  # Cogs.def latex(term) do
  #   IO.inspect term
  #   term = URI.encode term, fn _ -> false end
  #   IO.inspect term
  #   embed = %Embed{description: "latex"}
  #   IO.inspect embed
  #   embed = Embed.image embed, "http://i.imgur.com/4AiXzf8.jpg"
  #   IO.inspect embed

  #   um = Embed.send "test", embed
  #   # image: "http://latex.codecogs.com/png.latex?#{term}.png"
  #   IO.inspect um
  # end
end

  