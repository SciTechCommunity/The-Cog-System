defmodule Cog.Events.Helpers do
  use Alchemy.Cogs
  alias Alchemy.{Cache,Client}
  alias Alchemy.{User,Message}
  import Cog.{Helpers}


    def confirm_role(message, role) do
    {:ok, %Alchemy.Guild.GuildMember{roles: roles}} = Cogs.member
    cond do
      role in roles -> :ok
      true -> :invalid_user
    end
  end

  def get_member(gid,mid) do
    case Cache.member gid, mid do
      {:ok, mem} -> mem
      {:error, _} -> {:ok, mem} = Client.get_member gid, mid
        mem
    end
  end

  def wait_for(message, fun) do
    IO.puts "waiting1"
    Cogs.wait_for :message, fun
  end

  def wait_for(message, condition, fun) do
    # IO.puts "waiting2"
    Cogs.wait_for :message, condition, fun
  end


end

defmodule Cog.Events.Welcome do
  use Alchemy.Events
  alias Alchemy.{Cache,Client}
  alias Alchemy.{User,Message}
  import Cog.{Helpers,Events.Helpers}

  @guild_id "232641658712358912"

  @greetings ["Hello!", "Hi!", "Hey!", "Howdy!", "Hiya!", "HeyHi!", "Greetings!", "Welcome!"]

  @visitor "292739861767782401"
  @mod "232642926813904896"
  @admin "232643093407465472"
  @manual "232641724386770945"
  @welcome "317915118060961793"

  Events.on_message(:greet)
  def greet(%Message{channel_id: @welcome, author: %User{bot: false}} = message) do
    cond do
	  message.mentions == [] -> unless @mod in (get_member @guild_id, message.author.id).roles, do: close message, 3*60
	  (message.mentions |> hd).id == "249991058132434945" -> 
        {:ok, rude} = Client.send_message @welcome, "You're either a dumbass or a smartass, but either way you're not getting in."
        close message, 0 ; close rude, 30
	  message.mentions == [message.author] && String.contains? message.content, ["#{message.author.id}", "read", @manual] ->
        spawn_monitor Client, :add_role, [ @guild_id, message.author.id, @visitor ]
        receive do _ -> Client.send_message @guild_id, "#{Enum.random(@greetings)} <@#{message.author.id}>!" end
        close message, 0
      true -> nil
    end
  end ; def greet(_), do: nil
end