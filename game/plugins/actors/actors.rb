$:.unshift File.dirname(__FILE__)
load "actors_interface.rb"
load "lib/actor_catcher.rb"
load "lib/actors_cmd.rb"
load "lib/actors_model.rb"
load "lib/delete_actor_cmd.rb"
load "lib/helpers.rb"
load "lib/search_actors_cmd.rb"
load "lib/set_actor_cmd.rb"
load "templates/actors_list.rb"

module AresMUSH
  module Actors
    def self.plugin_dir
      File.dirname(__FILE__)
    end
 
    def self.shortcuts
      Global.read_config("actors", "shortcuts")
    end
 
    def self.load_plugin
      self
    end
 
    def self.unload_plugin
    end
 
    def self.help_files
      [ "help/actors.md", "help/admin_actors.md" ]
    end
 
    def self.config_files
      [ "config_actors.yml" ]
    end
 
    def self.locale_files
      [ "locales/locale_en.yml" ]
    end
 
    def self.handle_command(client, cmd)
       Global.dispatcher.temp_dispatch(client, cmd)
    end

    def self.handle_event(event)
    end
  end
end