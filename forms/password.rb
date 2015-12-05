require 'virtus'
require 'active_model'

# Form Object to deal with passwords
class CreatePasswordForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :password
  attribute :password_confirmation
  validates :password, presence: true
  validates :password_confirmation, presence: true
  validates :password, confirmation: true

  def error_message
    errors.full_messages.map(&:to_s).join('; ')
  end
end
