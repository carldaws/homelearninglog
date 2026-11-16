class InvitationsController < ApplicationController
  before_action :no_store, only: :show

  def new
    @invitation = Current.user.invitations.build(children: Current.user.children.where(id: params[:child_id]))
  end

  def create
    @invitation = Current.user.invitations.build(invitation_params)

    if @invitation.save
      redirect_to @invitation
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @invitation = Current.user.invitations.unexpired.find(params[:id])
  end

  private
    def invitation_params
      params.expect(invitation: [ child_ids: [] ])
    end
end
