require_relative '../helpers/model_helpers'

# Class for Canvas tokens
class Token < ActiveRecord::Base
  include ModelHelper

  validates :email, presence: true, uniqueness: true, format: /@/
  validates :encrypted_token, presence: true

  attr_accessible :email

  def token=(params)
    self.encrypted_token = enc_64(enc.encrypt(dec_64(nonce), "#{params}"))
  end

  def token
    dec.decrypt(dec_64(nonce), dec_64(encrypted_token))
  end
end
