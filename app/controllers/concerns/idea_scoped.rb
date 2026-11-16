module IdeaScoped
  extend ActiveSupport::Concern
  include ChildScoped

  included do
    before_action :set_idea
  end

  private
    def set_idea
      @idea = @child.ideas.find(params[:idea_id])
    end
end
