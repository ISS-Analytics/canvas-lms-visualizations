require 'virtus'
require 'active_model'

# Form Object to deal with passwords
class SaveTokenForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :url
  attribute :token
  validates :url, presence: true
  validates :token, presence: true

  def error_message
    errors.full_messages.map(&:to_s).join('; ')
  end
end
