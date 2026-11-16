class EventsController < ApplicationController
  include FamilyScoped

  before_action :require_children, only: %i[ new create ]
  before_action :set_event, only: %i[ edit update destroy ]

  def new
    @event = Current.family.draft_event(on: params[:date])
  end

  def create
    @event = Current.family.events.build(event_params)

    if @event.save
      redirect_to calendar_path(week: @event.starts_on)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to calendar_path(week: @event.starts_on)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy!
    redirect_to calendar_path, status: :see_other
  end

  private
    def set_event
      @event = Current.family.events.find(params[:id])
    end

    def event_params
      params.expect(event: [ :title, :activity_id, :grown_up_id, :starts_on, :start_time, :end_time, :repeats, :repeats_until, :notes, child_ids: [] ])
    end
end
