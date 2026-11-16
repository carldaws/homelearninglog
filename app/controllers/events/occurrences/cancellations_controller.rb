class Events::Occurrences::CancellationsController < ApplicationController
  include OccurrenceScoped

  def create
    @occurrence.cancel
    redirect_to child_calendar_path(@child, week: @occurrence.date)
  end

  def destroy
    @occurrence.restore
    redirect_to child_calendar_path(@child, week: @occurrence.date), status: :see_other
  end
end
