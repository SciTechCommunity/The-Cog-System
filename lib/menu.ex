defmodule Cog.Menu.Helpers do
  def contributors do
    %{
      "<@&339205216068960259>" => ["<@249991058132434945>"], # @Menu
      "<@&339118234441875457>" => ["<@249991058132434945>"], # @Admin
      "<@&339113373486809099>" => ["<@249991058132434945>"], # @VantagePoint
      "<@&339555180553175060>" => ["<@249991058132434945>"], # @Resource
    }
  end
  def details do
    %{
      "<@&339205216068960259>" => "The <@&339205216068960259> Cog is the Cog that runs the system menu interface for the Cog system it provides helpful information on the other Cogs and also serves as a directory for turning and rusted Cogs.", # @Menu
      "<@&339118234441875457>" => "The <@&339118234441875457> Cog provides access to Moderator like commands such as mute and clear. These commands should only be used by Mods and Admins.", # @Admin
      "<@&339113373486809099>" => "The <@&339113373486809099> Cog is a WIP stock market simulator. Once completed it will allow users to manage virtual portfolios using a digital currency and data on openly traded companies.", # @VantagePoint
      "<@&339555180553175060>" => "The <@&339555180553175060> Cog is a WIP collection of free digital resources for the aspiring Computer Scientist!", # @Resource
    }
  end
end


defmodule Cog.Menu do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Client,Embed}
  import Cog.{Helpers,Menu.Helpers}

  Cogs.group("<@&339205216068960259>") # @Menu

  

  Cogs.def open do
    close message, 0
    {:ok, menu} = Cogs.say """
    loading menu...

    ######################################
    ############# ***__Cog System Menu__***  ############
    ######################################
    **__Turning Cogs:__**
      |> Base
      |> ~~@LaTeX~~
      |> <@&339205216068960259>
      |> <@&339113373486809099>
      |> <@&339118234441875457>
      |> <@&339555180553175060>

    **__Menu Commands:__**
      |> `about`
      |> `help`

    **__Cog Directives:__**
      |> `credits <Cog>`
      |> `details <Cog>`
    ~~*(this menu will self destruct in 10 seconds)*~~
    """
    
    close menu, 10
  end

  Cogs.def about do
    close message, 0
    {:ok, you} = Cogs.say """
    loading about...

    The Cog System is a program management system that runs across multiple small computing nodes and handles the passing of data between said nodes.

    While Cog runs on the BEAM VM and is written primarily in Elixir and Erlang, it is fully capable of interfacing with programs written in any language and currently utilizes some libraries written in <@&306483387584217089> and <@&306483049003220996>.

    Members of the CSST are encouraged to produce their own Cogs that can be added to the system and extend it's functionality.

    This allows newer programmers who are unfamiliar with networking and API usage to create their own working discord commands.

    Unfortunately, due to the nature of some of the setup of the Cog System, the project is not open source.

    Programmers who create their own Cogs will have access to some information about the system, but not all of it's inner workings.

    Those who are interested in joining Project Cog or any of the other sub projects in the Cog System such as <@&339113373486809099>, please contact <@249991058132434945>.

    ~~*(this message will self destruct in 60 seconds)*~~
    """
    close you, 60
  end

  Cogs.def help do
    close message, 0
    {:ok, this} = Cogs.say """
    loading help...

    Commands in the Cog System have 3 parts: The base (@Cog), the Cog (@Menu), and the command (help).

    Some commands will take additional parameters. These are marked as required `<param>`, optional `(param)`, or a choice between two `[param | param]`.

    Parameter followed by a `...` like `<params...>` indicate that it is possible to pass multiple parameters.

    This is sometimes followed by number to indicate the amount of params passable, such as: `<param...2>`

    You can see the turning(active) and rusted(deactivated) Cogs in the system menu as well as the other commands available from the Menu Cog.

    Cog directives are commands you can use on other Cogs from the menu screen.
    These involve things like getting more info on the Cog's function and listing the contributors who helped create the Cog.
    ~~*(this message will self destruct in 30 seconds)*~~
    """
    close this, 30
  end

  Cogs.def details(cog) do
    close message, 2
    {:ok, old} = case Map.get details(), cog, nil do
      info when is_binary(info) -> info
      nil -> "This is not a valid Cog!"
    end |> Cogs.say
    close old, 10
  end

  Cogs.def credits(cog) do
    close message, 2
    {:ok, old} = case Map.get contributors(), cog, nil do
      authors when is_list(authors) -> Enum.reduce authors, "This Cog was contributed to by the following programmers:", (fn x, acc -> acc <> " " <> x end)
      nil -> "This is not a valid Cog!"
    end |> Cogs.say
    close old, 5
  end

end