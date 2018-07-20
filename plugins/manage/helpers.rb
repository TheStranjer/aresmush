module AresMUSH
  module Manage
    def self.can_manage_game?(actor)
      return false if !actor
      actor.has_permission?("manage_game")
    end
    
    def self.can_announce?(actor)
      return false if !actor
      actor.has_permission?("announce")
    end
    
    def self.can_manage_rooms?(actor)
      return false if !actor
      actor.has_permission?("build") || self.can_manage_game?(actor)
    end
    
    def self.is_owner_of_room?(actor, model)
      if model.class == Room
        model.room_owner == actor.id
      elsif model.class == Exit
        model.source.room_owner == actor.id && model.dest.room_owner == actor.id
      else
        false
      end
    end

    def self.can_manage_object?(actor, model)
      return false if !actor
      if (model.class == Room || model.class == Exit)
        self.can_manage_rooms?(actor) || self.is_owner_of_room?(actor, model)
      else
        self.can_manage_game?(actor)
      end
    end
    
    def self.perform_backup(client = nil)
      type = Global.read_config("backup", "backup_type")
      case (type.downcase)
      when "aws"
        backup = AwsBackup.new
        backup.backup(client)
      when "local"
        backup = LocalBackup.new
        backup.backup(client)
      else
        Global.logger.warn "Invalid backup type: #{type}"
        client.emit_failure t('manage.backups_not_enabled') if client
      end
    end
      
    def self.create_backup_file
      db_path = Global.read_config("database", "path")
      timestamp = Time.now.strftime("%Y%m%d%k%M%S")        
      backup_filename = "#{timestamp}-backup.zip"
      backup_dir = File.join(AresMUSH.root_path, "backups")
      backup_path = File.join(backup_dir, backup_filename)
      
      if (!Dir.exist?(backup_dir))
        Dir.mkdir(backup_dir)
      end
      
      Zip::File.open(backup_path, 'w') do |zipfile|
        Dir["#{AresMUSH.game_path}/**/**"].each do |file|
          zipfile.add(file.sub(AresMUSH.game_path+'/',''),file)
        end
        zipfile.add('dump.rdb', db_path)
      end
      
      backup_path
    end
  end
end
