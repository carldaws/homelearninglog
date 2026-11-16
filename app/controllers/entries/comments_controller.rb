class Entries::CommentsController < ApplicationController
  include ChildScoped

  before_action :set_entry
  before_action :set_comment, only: %i[ edit update destroy ]

  def create
    @comment = @entry.comments.build(comment_params.merge(author: Current.user))

    if @comment.save
      redirect_back_or_to helpers.entry_in_log_path(@entry)
    else
      redirect_back_or_to helpers.entry_in_log_path(@entry), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to helpers.entry_in_log_path(@entry)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @comment.destroy!
    redirect_to helpers.entry_in_log_path(@entry), status: :see_other
  end

  private
    def set_entry
      @entry = @child.entries.find(params[:entry_id])
    end

    def set_comment
      @comment = @entry.comments.where(author: Current.user).find(params[:id])
    end

    def comment_params
      params.expect(comment: [ :body ])
    end
end
