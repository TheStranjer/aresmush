module AresMUSH
  module Lucidity
    class RoleChangedEventHandler
      def on_event(event)
        char = Character[event.char_id]

        return if char.roles.none? { |r| r.name_upcase == "APPROVED" }

        area = Area.create(
          :name        => t('lucidity.start_room.area_name', :character => char.name),
          :description => t('lucidity.start_room.area_description', :character => char.name)
          )

        room = Room.create(
          :name        => t('lucidity.start_room.name'),
          :description => t('lucidity.start_room.description'),
          :room_owner  => char.id,
          :area        => area)

        area.rooms << room
        area.save

        char.room_home = room
        char.initiated = true

        char.save

        client = char.client

        return if client.nil?

        client.emit t('lucidity.start_room.approval_message')
        Rooms.move_to(client, char, room)
      end
    end
  end
end
