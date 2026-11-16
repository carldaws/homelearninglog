class EntriesController < ApplicationController
  include ChildScoped

  before_action :set_entry, only: %i[ edit update destroy ]

  def new
    @entry = @child.draft_entry
  end

  def create
    @entry = @child.entries.build(entry_params.merge(author: Current.user))

    if @entry.save
      redirect_to @child
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      redirect_to @child
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @entry.destroy!
    redirect_to @child, status: :see_other
  end

  private
    def set_entry
      @entry = @child.entries.find(params[:id])
    end

    def entry_params
      params.expect(entry: [ :what_we_did, :what_was_learned, :happened_on, :minutes, :event_id, :followed_idea_id, photos: [], ideas_attributes: [ [ :id, :description ] ] ])
    end
end
