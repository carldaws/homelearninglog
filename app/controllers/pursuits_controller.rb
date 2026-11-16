class PursuitsController < ApplicationController
  include FamilyScoped

  before_action :set_pursuit, only: %i[ show edit update destroy ]

  def index
    @pursuits = Current.family.pursuits.alphabetically.includes(:children)
  end

  def show
  end

  def new
    @pursuit = Current.family.draft_pursuit
  end

  def create
    @pursuit = Current.family.pursuits.build(pursuit_params)

    if @pursuit.save
      redirect_to @pursuit
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @pursuit.update(pursuit_params)
      redirect_to @pursuit
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @pursuit.destroy!
    redirect_to pursuits_path, status: :see_other
  end

  private
    def set_pursuit
      @pursuit = Current.family.pursuits.find(params[:id])
    end

    def pursuit_params
      params.expect(pursuit: [ :name, :notes, :started_on, child_ids: [] ])
    end
end
