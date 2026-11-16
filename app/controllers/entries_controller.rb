class EntriesController < ApplicationController
  include FamilyScoped

  before_action :set_entry, only: %i[ edit update destroy ]

  def index
    @log = Current.family.log(through: params[:through])
  end

  def new
    @entry = Current.family.entries.build(happened_on: Date.current, children: Current.family.children)
  end

  def create
    @entry = Current.family.entries.build(author: Current.user)

    if @entry.update(entry_params)
      redirect_to root_path, notice: t(".added")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      redirect_to root_path, notice: t(".saved")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @entry.destroy!
    redirect_to root_path, notice: t(".deleted"), status: :see_other
  end

  private
    def set_entry
      @entry = Current.family.entries.find(params[:id])
    end

    def entry_params
      params.expect(entry: [ :notes, :happened_on, :minutes, child_ids: [], photos: [] ])
    end
end
