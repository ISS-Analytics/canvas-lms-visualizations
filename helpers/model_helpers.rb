require 'base64'
require 'rbnacl/libsodium'
require 'json'
require 'protected_attributes'

# Helper module for models
module ModelHelper
  def key
    dec_64(ENV['DB_KEY'])
  end

  def enc_64(value)
    Base64.urlsafe_encode64(value)
  end

  def dec_64(value)
    Base64.urlsafe_decode64(value)
  end

  def box
    RbNaCl::SecretBox.new(key)
  end

  # def enc
  #   value = enc_64(RbNaCl::Random.random_bytes(dec.nonce_bytes))
  #   @nonce ||= nonce(special_key, value)
  #   self.nonce = @nonce
  #   dec
  # end
end
