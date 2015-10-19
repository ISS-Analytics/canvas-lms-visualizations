require_relative '../helpers/model_helpers'

# Class for Canvas tokens
class Token < ActiveRecord::Base
  include ModelHelper

  validates :email, presence: true, format: /@/
  validates :canvas_url, presence: true
  validates :encrypted_token, presence: true

  attr_accessible :email, :canvas_url

  def canvas_token=(params)
    self.encrypted_token = enc_64(enc.encrypt(dec_64(nonce), "#{params}"))
  end

  def canvas_token
    dec.decrypt(dec_64(nonce), dec_64(encrypted_token))
  end

  def canvas_token_display
    canvas_token[0..6] + '*' * 7
  end

  def canvas_api
    canvas_url + 'api/v1/'
  end
end
