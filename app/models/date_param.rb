module DateParam
  def self.cast(value)
    case value
    in String | Date then ActiveModel::Type::Date.new.cast(value)
    else nil
    end
  end
end
