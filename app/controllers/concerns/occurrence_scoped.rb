module OccurrenceScoped
  extend ActiveSupport::Concern
  include ChildScoped

  included do
    before_action :set_occurrence
  end

  private
    def set_occurrence
      @occurrence = @child.events.find(params[:event_id]).occurrence_on(occurrence_date)
    end

    def occurrence_date
      DateParam.cast(params[:occurrence_date]) || raise(ActiveRecord::RecordNotFound)
    end
end
