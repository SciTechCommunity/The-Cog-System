defmodule Cog.Sudo.Helpers do
  use Alchemy.Cogs
  alias Alchemy.{Client}
  import Cog.Helpers

  @mod "232642926813904896"
  @admin "232643093407465472"

  def confirm(message) do
    {:ok, %Alchemy.Guild.GuildMember{roles: roles}} = Cogs.member
    :ok = cond do
      # @admin in roles -> :ok
      @mod in roles -> :ok
      true -> :invalid_user
    end
  end

  def induction(m) do
  """
  Rejoice #{m}, for you have been accepted as an official member of CSST!
  Be sure to check out the new channels available in the member area!
  Thank you for joining us, we look forward to your contributions!
  """
  end
end

defmodule Cog.Sudo do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers,Sudo.Helpers}

  @visitor "292739861767782401"
  @member "235927353832767498"

  Cogs.group("@&339118234441875457>") # @Sudo
  
  Cogs.set_parser(:clear, fn message ->
    message = message |> String.split
    message = case message do
      ["<" <> m, n] -> [Regex.run(~r{\d+}, m) |> hd, String.to_integer(n)]
      ["<" <> m] -> [Regex.run(~r{\d+}, m) |> hd, 10]
      [n] -> [String.to_integer(n)]
    end
    message
  end)

  Cogs.def clear(m, n) do
    {:ok, old} = Cogs.say "deleting the last #{n} messages from <@#{m}>..."
    {:ok, messages} = Client.get_messages message.channel_id, before: message.id
    messages = Enum.filter(messages, fn message ->
      message.author.id == m
    end) |> Enum.chunk_every(n)
    |> hd
    |> (&Client.delete_messages(message.channel_id, [message | &1])).()
    close old, 3
  end
  Cogs.def clear(n) do
    confirm message
    {:ok, old} = Cogs.say "deleting #{n} messages..."
    {:ok, messages} = message.channel_id
      |> Client.get_messages(before: message.id, limit: n)
    message.channel_id |> Client.delete_messages [message | messages]

    # You can't see this
    close old, 3
  end

  Cogs.def induct(m) do
    confirm message
    close message, 0
    {:ok, old} = Cogs.say induction(m)
    {{:ok,id}, [m]} = {Cogs.guild_id, Regex.run(~r{\d+}, m)}
    Client.add_role id, m, @member
    Client.remove_role id, m, @visitor
    close old, 30
  end

  Cogs.def anoint(m,r) do
    confirm message
    close message, 0
    {:ok, old} = Cogs.say "Annointing #{m} with the #{r} role...."
    {[r], [m]} = {Regex.run(~r{\d+}, r), Regex.run(~r{\d+}, m)}
    {:ok, id} = Cogs.guild_id
    Client.add_role id, m, r
    close old, 3
  end

  Cogs.def revoke(m,r) do
    confirm message
    close message, 0
    {:ok, old} = Cogs.say "Revoking the #{r} role from #{m}...."
    {[r], [m]} = {Regex.run(~r{\d+}, r), Regex.run(~r{\d+}, m)}
    {:ok, id} = Cogs.guild_id
    Client.remove_role id, m, r
    close old, 3
  end

  Cogs.set_parser(:status, &List.wrap/1)
  Cogs.def status, do: Alchemy.Client.update_status(playing: "The Cog System")
  Cogs.def status(next), do: Alchemy.Client.update_status(playing: next)
end