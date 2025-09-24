module AresMUSH
  module Scenes
    
    def self.custom_char_card_fields(char, viewer)
      
    def self.get_fields_for_viewing(char, viewer)
      return {
          items: Simpleinventory.get_items(char)
      }
    end
      
      # Otherwise return a hash of data.  For example, if you want to show traits you could do:
      # {
      #   traits: char.traits.map { |k, v| { name: k, description: v } }
      # }
    end
  end
end
