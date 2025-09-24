module AresMUSH
  module Scenes
    
    def self.custom_char_card_fields(char, viewer)
      {
        items: Simpleinventory.get_items(char)
      }
    end
  end
end
