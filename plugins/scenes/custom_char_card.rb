module AresMUSH
  module Scenes
    
    def self.custom_char_card_fields(char, viewer)
      
    def self.get_fields_for_viewing(char, viewer)
      return {
          items: Simpleinventory.get_items(char)
      }
    end
    end
  end
end
