class ChildrenController < ApplicationController
  before_action :set_child, only: %i[ show edit update destroy ]

  def show
    @now = @child.now
  end

  def new
    @child = Child.new
  end

  def create
    @child = Current.user.children.create(child_params)

    if @child.persisted?
      redirect_to @child
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @child.update(child_params)
      redirect_to child_settings_path(@child)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if params[:confirmation] == @child.name
      @child.destroy!
      redirect_to root_path, status: :see_other
    else
      redirect_to new_child_removal_path(@child), alert: t(".unconfirmed"), status: :see_other
    end
  end

  private
    def set_child
      @child = Current.user.children.find(params[:id])
    end

    def child_params
      params.expect(child: [ :name ])
    end
end
