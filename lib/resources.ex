defmodule Cog.Resource.Helpers do
end

defmodule Cog.Resource do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers,Resource.Helpers}

  Cogs.group("<@&339555180553175060>") # @Resource

  Cogs.def packt do
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
      [h,m,s] = String.split(x, ":")
      "#{h}h:#{m}m:#{s}s"
    end
    time = (String.to_integer time) - (DateTime.to_unix DateTime.utc_now) |> DateTime.from_unix! |> DateTime.to_time |> Time.to_string |> format.()
    

    [link] = body
      |> Floki.find(".dotd-main-book-image")
      |> Floki.attribute("a", "href")

    Cogs.say """
    ***Free eBook each day at PacktPub!***
    Today's book is: **#{title}**.
    You still have **#{time}** to pick it up @
    https://www.packtpub.com/packt/offers/free-learning
    You can **support the author** by purchasing this book @
    https://www.packtpub.com#{link}
    """
  end

  Cogs.def packt(book) do
    Cogs.say """
    Find books related to **#{book}** on Packt for only **10 USD**!

    https://www.packtpub.com/all?search=#{URI.encode book, &is_nil/1}
    """
  end
end
