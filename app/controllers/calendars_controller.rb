class CalendarsController < ApplicationController
  include FamilyScoped

  def show
    @week = Current.family.week(containing: params[:week])
  end
end
