class Weeks::ReflectionsController < ApplicationController
  include FamilyScoped

  def update
    week = Current.family.week(containing: params[:week])
    week.reflection.update!(params.expect(reflection: [ :notes ]))
    redirect_to week_path(week: week.starts_on), status: :see_other
  end
end
