class EventsController < ApplicationController
  include ChildScoped

  before_action :set_event, only: %i[ edit update destroy ]

  def new
    @event = @child.draft_event(on: params[:date])
  end

  def create
    @event = @child.events.build(event_params)

    if @event.save
      redirect_to child_calendar_path(@child, week: @event.starts_on)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to child_calendar_path(@child, week: params[:week].presence || @event.starts_on)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy!
    redirect_to child_calendar_path(@child, week: params[:week]), status: :see_other
  end

  private
    def set_event
      @event = @child.events.find(params[:id])
    end

    def event_params
      params.expect(event: [ :title, :grown_up_id, :starts_on, :start_time, :end_time, :repeats, :repeats_until, :notes ])
    end
end
