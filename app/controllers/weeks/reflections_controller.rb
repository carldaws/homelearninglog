class Weeks::ReflectionsController < ApplicationController
  include FamilyScoped

  def update
    week = Current.family.week(containing: params[:week])
    Current.family.reflections.create_or_find_by!(week_of: week.starts_on).update!(params.expect(reflection: [ :notes ]))
    redirect_to week_path(week: week.starts_on), status: :see_other
  end
end
