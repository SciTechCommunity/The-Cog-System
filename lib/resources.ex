defmodule Cog.Resource.Helpers do
  use Alchemy.Cogs
  alias Alchemy.{Client}
  import Cog.Helpers

  def load(:packt) do
    html = (HTTPoison.get! "https://www.packtpub.com/packt/offers/free-learning").body
    body = Floki.find html, "#deal-of-the-day"

    [{_,_,[title]} | _] = body
      |> Floki.find(".dotd-title")
      |> Floki.find("h2")
    title = String.trim title

    [time] = body
      |> Floki.find(".packt-js-countdown")
      |> Floki.attribute("data-countdown-to")
    format = fn x ->
      [h,m,s] = String.split(x, ":") |> Enum.map(&String.to_integer/1)
      "#{h} hours, #{m} minutes, and #{s} seconds"
    end
    time = (String.to_integer time) - (DateTime.to_unix DateTime.utc_now) |> DateTime.from_unix! |> DateTime.to_time |> Time.to_string |> format.()
    

    [link] = body
      |> Floki.find(".dotd-main-book-image")
      |> Floki.attribute("a", "href")

    """
    ***Free eBook each day at PacktPub!***
    Today's book is: **#{title}**.
    You still have **#{time}** to pick it up @
    https://www.packtpub.com/packt/offers/free-learning
    You can **support the author** by purchasing this book @
    https://www.packtpub.com#{link}
    """
  end

  def load(_) do
    IO.puts "Invalid resource!"
  end

  def ping_subs do
    send :subs, {:dump, self()}
    subs = receive do
      dump ->
        IO.inspect dump
        data = for {sub, ids} <- dump do
          unless ids == [] do
          Client.send_message "235823577813876736", """
          #{load sub}
          #{for id <- ids, into: "", do: "<@#{id}>"}
          """, [tts: true]
          end
        end
        IO.inspect data
        dump
    end
    Process.sleep 3600*12*1000
    ping_subs
  end
end

defmodule Cog.Resource do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers,Resource.Helpers}

  Cogs.group("<@&339555180553175060>") # @Resource

  Cogs.def packt do
    Cogs.say load :packt
  end

  Cogs.def packt(book) do
    Cogs.say """
    Find books related to **#{book}** on Packt for only **10 USD**!

    https://www.packtpub.com/all?search=#{URI.encode book, &is_nil/1}
    """
  end
  
  Cogs.def unsubscribe("packt") do
    id = String.to_integer message.author.id
    send :subs, {:unsubscribe, :packt, id}
    {:ok, alert} = Cogs.say "<@#{id}> You have unsubscribed to the daily packt ebook!"
    close alert, 5
  end

  Cogs.def subscribe("packt") do
    IO.inspect "here"
    id = String.to_integer message.author.id
    send :subs, {:subscribe, :packt, id}
    {:ok, alert} = Cogs.say "<@#{id}> You have subscribed to the daily packt ebook!"
    close alert, 5
  end
end

defmodule Subscriptions do
  import Cog.{Helpers,Resource.Helpers}

  def start(data \\ %{packt: []}) do
    Process.register self(), :subs
    # send :subscriber, {:start, data}
    spawn Cog.Resource.Helpers, :ping_subs, []
    listen data
  end

  def listen(data) do
    receive do
      {:subscribe, sub, id} ->
        new_sub = if is_nil(data[sub]), do: [], else: data[sub]
        Map.put data, sub, [id | new_sub]
      {:unsubscribe, sub, id} ->
        new_sub = Enum.reject data[sub], fn x -> x == id end
        Map.put data, sub, new_sub
      {:list, sub, sender} ->
        send sender, data[sub]
        data
      {:dump, sender} ->
        send sender, data
        data
      err ->
        IO.inspect err
        data
    end |> listen
  end
end