class FamiliesController < ApplicationController
  include FamilyScoped

  skip_before_action :require_family, only: %i[ new create ]
  before_action :redirect_to_family, only: %i[ new create ], if: -> { Current.family.present? }

  def show
  end

  def new
    @family = Family.new
  end

  def create
    @family = Current.user.start_family(family_params)

    if @family.persisted?
      redirect_to new_family_child_path, notice: t(".started")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if Current.family.update(family_params)
      redirect_to family_path, notice: t(".renamed")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def family_params
      params.expect(family: [ :name ])
    end

    def redirect_to_family
      redirect_to family_path
    end
end
