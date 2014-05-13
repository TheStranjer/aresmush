module AresMUSH
  module Bbs
    class BbsReplyCmd
      include Plugin
      include PluginRequiresLogin
      include PluginRequiresArgs
      
      attr_accessor :board_name, :num, :reply

      def initialize
        self.required_args = ['reply']
        self.help_topic = 'bbs'
        super
      end
      
      def want_command?(client, cmd)
        cmd.root_is?("bbs") && cmd.switch_is?("reply")
      end
            
      def crack!
        puts cmd.args.inspect
        if (cmd.args !~ /.+\/.+\=/)
          self.reply = cmd.args
        else
          cmd.crack!( /(?<name>[^\=]+)\/(?<num>[^\=]+)\=(?<reply>[^\=]+)/)
          self.board_name = titleize_input(cmd.args.name)
          self.num = trim_input(cmd.args.num)
          self.reply = cmd.args.reply
        end
      end
      
      def handle
        post = client.program[:last_bbs_post]
        if (!post.nil?)
          post = client.program[:last_bbs_post]
          board = post.bbs_board
          save_reply(board, post)
        else
          if (self.board_name.nil? || self.num.nil?)
            client.emit_failure t('dispatcher.invalid_syntax', :command => 'bbs')
            return
          end
          Bbs.with_a_post(self.board_name, self.num, client) do |board, post|
            save_reply(board, post)
          end
        end
      end
      
      def save_reply(board, post)
        if (!Bbs.can_write_board?(client.char, board))
          client.emit_failure(t('bbs.cannot_post'))
          return
        end

        date = DateTime.now.strftime("%Y-%m-%d")
        post.message = post.message + "%r%r" + t('bbs.reply', :author => client.char.name, :reply => self.reply, :date => date)
        post.mark_unread
        Global.client_monitor.emit_all_ooc t('bbs.new_reply', :subject => post.subject, :board => board.name, :author => client.name)
        client.program.delete(:last_bbs_post)
      end
    end
  end
end