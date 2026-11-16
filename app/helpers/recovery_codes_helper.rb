module RecoveryCodesHelper
  def grouped_recovery_code(code)
    code.scan(/.{1,4}/).join(" ")
  end
end
