class FxSignal::Updater::Base

    def data
      @data ||= (
        @document.payload.try(:parts).try(:first).try(:body).try(:data) || 
        @document.payload.try(:body).try(:data)
      )
    end

end

