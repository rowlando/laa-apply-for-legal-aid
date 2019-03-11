module CCMS
  class PayloadKeys
    KEYS = {
      AAABBB: {
        br100_meaning: 'the meaning of life',
        response_type: :text,
        user_defined: true,
        response_value: '#generation_method'
      },
      AAABBC: {
        br100_meaning: 'the meaning of life v2',
        response_type: :boolean,
        user_defined: true,
        response_value: true
      },
    }
  end


  def generation_method
    "Unknown value"
  end


end
