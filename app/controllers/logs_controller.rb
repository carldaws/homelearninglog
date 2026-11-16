class LogsController < ApplicationController
  include ChildScoped

  def show
    @log = @child.log(through: params[:through])
  end
end
