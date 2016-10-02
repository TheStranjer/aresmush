module AresMUSH
  class Character
    attribute :admin_note
    
    def is_admin?
      self.has_any_role?(Global.read_config("roles", "game_admin"))
    end
  end  
end