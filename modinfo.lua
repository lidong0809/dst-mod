name = "Wurt: Friendly Marsh Life"
description = "QoL tweaks for Wurt: Pig King trading, neutral pigs, immortal Merm King hunger, and wet/snow cold protection."
author = "Codex"
version = "1.0.0"

forumthread = ""
api_version = 10
api_version_dst = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
hamlet_compatible = false

all_clients_require_mod = false
client_only_mod = false
server_only_mod = true

icon_atlas = ""
icon = ""

configuration_options = {
  {
    name = "pig_king_trade",
    label = "Wurt can trade with Pig King",
    hover = "Allows Wurt to trade normal Pig King items.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "pig_neutral",
    label = "Pigs are neutral to Wurt",
    hover = "Pigmen and pig guards will not target Wurt unless she attacks.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "mermking_no_hunger_loss",
    label = "Merm King never starves",
    hover = "Keeps the Merm King fed so he will not lose level from hunger.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "wet_snow_cold_protection",
    label = "Wet/snow cold protection",
    hover = "Wurt will not freeze from wetness; snow counts as the same protection without raising wetness.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
}
