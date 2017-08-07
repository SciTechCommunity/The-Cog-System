defmodule Cog.Vantage do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers}

  Cogs.group("<@&339113373486809099>") # @VantagePoint

  # Cogs.set_parser(:test, &List.wrap/1)
  Cogs.def test(term) do
    send :brain, term
  end

  # Cogs.set_parser(:test, &List.wrap/1)
  Cogs.def quote(term) do
    close message, 1
    {:ok, old} = Cogs.say "loading stock market data..."
    send :brain, {:quote, self, term}
    receive do
      {:ok, {sym, zone, time, cur, high, low}} ->
        Client.edit_message old, """
          Symbol: #{sym}
          Time: #{time}, #{zone}
          Current: #{cur}
          High: #{high}
          Low: #{low}
          """
      {:error, reason} ->
        Client.edit_message old, "#{inspect reason}"
      that -> IO.inspect that
    end
  end

  Cogs.def watch(term) do
    send :brain, {:watch, self, String.to_integer(message.author.id), term}
    receive do
      that -> IO.inspect that
    end
  end

end

defmodule Vantage do
  def start(key, data \\ %{}) do
    Process.register self(), :brain
    send :brain, {:start, data}
    listen key
  end

  def listen(key, data \\ %{}) do
    receive do
      {:start, init} ->
        data = init
      {:quote, sender, stock} ->
        stock = stock |> poll(key)
        send sender, stock
      {:watch, sender, user, stock} ->
        {data, stock} = update_list data, user, stock
        send sender, stock
      that -> IO.inspect that # {:error, that}
    end
    listen data
  end

  def poll(stock, key) do
    case HTTPoison.get "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{stock}&apikey=#{key}" do
      {:ok, response} ->
        case Poison.decode response.body do
          {:ok, json} -> 
            %{"Meta Data" => %{"3. Last Refreshed" => time, "5. Time Zone" => zone}} = json
            %{"Time Series (Daily)" => %{^time => %{"2. high" => high, "3. low" => low, "4. close" => close}}} = json
            {:ok, {stock, zone, time, close, high, low}}
          fail -> fail
        end
      fail -> fail
    end
  end

  def update_list(data, user, stock) do
    IO.inspect {data, user, stock}
    # Map.get_and_update
    # IO.inspect "watching..."
    # {:ok, stock}
  end
end