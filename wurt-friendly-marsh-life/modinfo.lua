name = "Wurt: Friendly Marsh Life"
description = "QoL tweaks for Wurt: Pig King trading, neutral pigs, Wormwood-friendly merms, longer Merm loyalty, merm dismiss command, Chester-safe merms, slower Merm King hunger, and wetness cold protection."
author = "Codex"
version = "1.0.4"

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
    label = "Merm King hunger 1/5 speed",
    hover = "Reduces the Merm King's hunger drain to one fifth of the original speed.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "wet_snow_cold_protection",
    label = "Wetness cold penalty protection",
    hover = "Removes Wurt's wetness temperature penalty without blocking normal winter cold.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "merm_neutral_to_wormwood",
    label = "Merms are neutral to Wormwood",
    hover = "Merms and merm guards will not target Wormwood unless he attacks.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "merm_loyalty_multiplier",
    label = "Merm recruitment duration",
    hover = "Multiplies recruited Merm loyalty time and maximum follow time.",
    options = {
      { description = "Original", data = 1 },
      { description = "2x", data = 2 },
      { description = "3x", data = 3 },
      { description = "5x", data = 5 },
    },
    default = 2,
  },
  {
    name = "dismiss_merms_command",
    label = "Dismiss Merms command",
    hover = "Adds /dismissmerms to immediately dismiss your recruited Merm followers.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "merm_ignore_chester",
    label = "Merms ignore Chester",
    hover = "Merms and merm guards will not target Chester.",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
}
