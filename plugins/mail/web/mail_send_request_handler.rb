module AresMUSH
  module Mail
    class MailSendRequestHandler
      def handle(request)
        enactor = request.enactor
        message = request.args[:message]
        subject = request.args[:subject]
        to_list = request.args[:to_list]
       
        error = WebHelpers.check_login(request)
        return error if error

        if (!enactor.is_approved?)
          return { error: t('dispatcher.not_allowed') }
        end
        
        if (subject.blank? || message.blank? || to_list.blank?)
          return { error: t('webportal.missing_required_fields') }
        end
        
        message = WebHelpers.format_input_for_mush(message)
        
        sent = Mail.send_mail(to_list.split(" "), subject, message, nil, enactor)
        if (!sent)
          return { error: "website.unexpected_error" }
        end
        
        {
        }
      end
    end
  end
end