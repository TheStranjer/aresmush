module AresMUSH
  class Character
    def describe_cost(character)
      0
    end

    def award(bounty)
      return if bounty <= 0
      self.lucidity += bounty
      self.save

      client.emit t('lucidity.award', :bounty => bounty, :current => self.lucidity) unless client.nil?
    end

    def expend(payment)
      Global.logger.info("#{name} is trying to spend #{payment} Lucidity...")
      if self.lucidity < payment
        client.emit t('lucidity.not_enough', :required => payment, :current => self.lucidity)
        return
      end

      begin
        yield
        client.emit t('lucidity.you_spent', :payment => payment)
        self.lucidity -= payment
        self.save
      rescue => e
        client.emit t('lucidity.something_went_wrong')
        Global.logger.info("#{self.name} could not expend resources because #{e.message} \n\n#{e.backtrace.join("\n")}")
      end
    end
  end
end
