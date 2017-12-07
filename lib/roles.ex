defmodule Cog.Roles.Helpers do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Embed,Client}
  import Cog.Helpers
end

defmodule Cog.Roles do
  use Alchemy.Cogs
  require Alchemy.Embed
  alias Alchemy.{Cache,Client,Embed}
  import Cog.{Helpers,Roles.Helpers}

  Cogs.group("@338170415274917888>") # @Cog
end

