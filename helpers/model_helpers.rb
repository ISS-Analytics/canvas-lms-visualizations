require 'base64'
require 'rbnacl/libsodium'
require 'json'
require 'sinatra/activerecord'
require 'protected_attributes'
# require_relative '../environments'

# Helper module for models
module ModelHelper
  def key
    Base64.urlsafe_decode64(ENV['DB_KEY'])
  end

  def enc_64(value)
    Base64.urlsafe_encode64(value)
  end

  def dec_64(value)
    Base64.urlsafe_decode64(value)
  end

  def dec
    RbNaCl::SecretBox.new(key)
  end

  def enc
    @nonce = enc_64(RbNaCl::Random.random_bytes(dec.nonce_bytes)) unless @nonce
    self.nonce = @nonce
    dec
  end
end
