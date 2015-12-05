require_relative '../helpers/model_helpers'

# Class for Canvas tokens
class Token < ActiveRecord::Base
  include ModelHelper

  validates :email, presence: true, format: /@/
  validates :encrypted_url, presence: true
  validates :encrypted_token, presence: true

  attr_accessible :email

  def canvas_token=(arr)
    params = arr[0]
    special_key = arr[1]
    self.encrypted_access_key = base_64_encode(RbNaCl::Hash.sha256(params))
    self.encrypted_token = base_64_encode(
      secret_box.encrypt(base_64_decode(nonce(special_key)), "#{params}")
    )
  end

  def access_key
    encrypted_access_key[0..10]
  end

  def canvas_token(special_key)
    secret_box.decrypt(
      base_64_decode(nonce(special_key)), base_64_decode(encrypted_token)
    )
  end

  def canvas_url=(arr)
    url = arr[0]
    special_key = arr[1]
    url = url[-1] != '/' ? url + '/' : url
    self.encrypted_url = base_64_encode(
      secret_box.encrypt(base_64_decode(nonce(special_key)), "#{url}")
    )
  end

  def canvas_url(special_key)
    secret_box.decrypt(
      base_64_decode(nonce(special_key)), base_64_decode(encrypted_url)
    )
  end

  def nonce=(special_key)
    nonce_value = base_64_encode(
      RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
    )
    self.encrypted_nonce = base_64_encode(
      secret_box.encrypt(base_64_decode(special_key), nonce_value)
    )
  end

  def nonce(special_key)
    secret_box.decrypt(
      base_64_decode(special_key), base_64_decode(encrypted_nonce)
    )
  end

  def canvas_token_display(special_key)
    canvas_token(special_key)[0..10] + '*' * 7
  end

  def canvas_api(special_key)
    canvas_url(special_key) + 'api/v1/'
  end
end
