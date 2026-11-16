module User::Recoverable
  extend ActiveSupport::Concern

  RECOVERY_CODE_CHARACTERS = "ABCDEFGHJKMNPQRSTVWXYZ23456789".chars.freeze
  RECOVERY_CODE_LENGTH = 16

  included do
    has_secure_password :recovery_code, validations: false, reset_token: false

    before_validation :replace_recovery_code, on: %i[ create password_reset recovery_code_renewal ]
  end

  class_methods do
    def authenticate_by_recovery_code(email_address:, recovery_code:)
      authenticate_by(email_address:, recovery_code: recovery_code.upcase.delete("^#{RECOVERY_CODE_CHARACTERS.join}"))
    end
  end

  private
    def replace_recovery_code
      self.recovery_code = SecureRandom.alphanumeric(RECOVERY_CODE_LENGTH, chars: RECOVERY_CODE_CHARACTERS)
    end
end
