class ChildrenController < ApplicationController
  before_action :set_child, only: %i[ show edit update destroy ]

  def show
    @log = @child.log(through: params[:through])
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
      redirect_to @child
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @child.destroy
      redirect_to root_path, status: :see_other
    else
      redirect_to edit_child_path(@child), alert: @child.errors.full_messages.to_sentence, status: :see_other
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
