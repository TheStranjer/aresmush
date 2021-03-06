module AresMUSH
  module Scenes
    class CreatePlotRequestHandler
      def handle(request)
        enactor = request.enactor
        
        error = WebHelpers.check_login(request)
        return error if error
        
        if (!enactor.is_approved?)
          return { error: t('dispatcher.not_allowed') }
        end
        
        [ :title, :summary ].each do |field|
          if (request.args[field].blank?)
            return { error: t('webportal.missing_required_fields') }
          end
        end
        
        plot = Plot.create(
          title: request.args[:title],
          description: request.args[:description],
          summary: request.args[:summary]
        )
                
        { id: plot.id }
      end
    end
  end
end