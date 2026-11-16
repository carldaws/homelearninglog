class Families::ChildrenController < ApplicationController
  include FamilyScoped

  before_action :set_child, only: %i[ edit update destroy ]

  def new
    @child = Current.family.children.build
  end

  def create
    @child = Current.family.children.build(child_params)

    if @child.save
      redirect_to family_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @child.update(child_params)
      redirect_to family_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @child.destroy
      redirect_to family_path, status: :see_other
    else
      redirect_to edit_family_child_path(@child), alert: @child.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_child
      @child = Current.family.children.find(params[:id])
    end

    def child_params
      params.expect(child: [ :name ])
    end
end
