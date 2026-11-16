class CalendarsController < ApplicationController
  include ChildScoped

  def show
    @week = @child.week(containing: params[:week])
  end
end
