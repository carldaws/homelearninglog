class Events::Occurrences::CancellationsController < ApplicationController
  include FamilyScoped, OccurrenceScoped

  def create
    @occurrence.cancel
    redirect_to calendar_path(week: @occurrence.date)
  end

  def destroy
    @occurrence.restore
    redirect_to calendar_path(week: @occurrence.date), status: :see_other
  end
end
