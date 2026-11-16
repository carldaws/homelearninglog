class EntriesController < ApplicationController
  include FamilyScoped

  before_action :require_children, only: %i[ new create ]
  before_action :set_entry, only: %i[ edit update destroy ]

  def index
    @log = Current.family.log(through: params[:through])
  end

  def new
    @entry = Current.family.draft_entry
  end

  def create
    @entry = Current.family.entries.build(entry_params.merge(author: Current.user))

    if @entry.save
      redirect_to entries_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      redirect_to entries_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @entry.destroy!
    redirect_to entries_path, status: :see_other
  end

  private
    def set_entry
      @entry = Current.family.entries.find(params[:id])
    end

    def entry_params
      params.expect(entry: [ :notes, :happened_on, :minutes, :activity_id, :event_id, child_ids: [], photos: [] ])
    end
end
