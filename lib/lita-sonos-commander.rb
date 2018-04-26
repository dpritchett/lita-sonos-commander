require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/sonos_commander"
require "lita/commander_middleware"

Lita::Handlers::SonosCommander.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
