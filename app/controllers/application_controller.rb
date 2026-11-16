class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: { safari: 16.4, chrome: 111, firefox: 128 }

  stale_when_importmap_changes
end
