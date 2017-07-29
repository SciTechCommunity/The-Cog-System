defmodule Cog.Admin do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers,Commands.Helpers}

  Cogs.group("<@&339118234441875457>") # @Admin

  Cogs.def clear(n) do
    ch = message.channel_id
    n = n |> String.to_integer
    {:ok, old} = Cogs.say "deleting #{n} messages..."
    {:ok, messages} = ch
      |> Client.get_messages(before: message.id, limit: n)
    ch |> Client.delete_messages [message | messages]

    # You can't see this
    close old, 3
  end
end