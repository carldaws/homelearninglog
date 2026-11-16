ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module FixturePasswords
  PASSWORD = "correct horse battery"
  RECOVERY_CODE = "ABCDEFGHJKMNPQRS"

  def password_digest
    BCrypt::Password.create(PASSWORD, cost: BCrypt::Engine::MIN_COST)
  end

  def recovery_code_digest
    BCrypt::Password.create(RECOVERY_CODE, cost: BCrypt::Engine::MIN_COST)
  end
end

ActiveRecord::FixtureSet.context_class.include FixturePasswords

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    setup { Rails.cache.clear }
  end
end

module SignInHelper
  def sign_in_as(user, password: FixturePasswords::PASSWORD, headers: {})
    post session_path, params: { email_address: user.email_address, password: }, headers:
  end

  def assert_signed_in
    get new_session_path
    assert_redirected_to entries_path
  end

  def assert_not_signed_in
    get new_session_path
    assert_response :success
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
