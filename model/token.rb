require_relative '../helpers/model_helpers'

# Class for Canvas tokens
class Token < ActiveRecord::Base
  include ModelHelper

  validates :email, presence: true, format: /@/
  validates :canvas_url, presence: true
  validates :encrypted_token, presence: true

  attr_accessible :email, :canvas_url

  def canvas_token=(arr)
    params = arr[0]
    special_key = arr[1]
    self.encrypted_token = enc_64(box.encrypt(dec_64(nonce(special_key)),
                                              "#{params}"))
  end

  def canvas_token(special_key)
    box.decrypt(dec_64(nonce(special_key)), dec_64(encrypted_token))
  end

  def nonce=(special_key)
    nonce_value = enc_64(RbNaCl::Random.random_bytes(box.nonce_bytes))
    self.encrypted_nonce = enc_64(box.encrypt(dec_64(special_key), nonce_value))
  end

  def nonce(special_key)
    box.decrypt(dec_64(special_key), dec_64(encrypted_nonce))
  end

  def canvas_token_display(special_key)
    canvas_token(special_key)[0..10] + '*' * 7
  end

  def canvas_api
    canvas_url + 'api/v1/'
  end
end
