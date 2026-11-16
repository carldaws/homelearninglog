class ActivitiesController < ApplicationController
  include FamilyScoped

  before_action :set_activity, only: %i[ show edit update destroy ]

  def index
  end

  def show
  end

  def new
    @activity = Current.family.activities.build
  end

  def create
    @activity = Current.family.activities.build(activity_params)

    if @activity.save
      redirect_to @activity
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @activity.update(activity_params)
      redirect_to @activity
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @activity.destroy!
    redirect_to activities_path, status: :see_other
  end

  private
    def set_activity
      @activity = Current.family.activities.find(params[:id])
    end

    def activity_params
      params.expect(activity: [ :name, :minutes, :notes ])
    end
end
