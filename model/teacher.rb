require_relative '../helpers/model_helpers'

# Class for Canvas teachers
class Teacher < ActiveRecord::Base
  include ModelHelper

  validates :email, presence: true, uniqueness: true, format: /@/
  validates :hashed_password, presence: true

  attr_accessible :email

  def password=(new_password)
    salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    digest = self.class.hash_password(salt, new_password)
    self.salt = enc_64(salt)
    self.hashed_password = enc_64(digest)
  end

  def self.hash_password(salt, pwd)
    opslimit = 2**20
    memlimit = 2**24
    RbNaCl::PasswordHash.scrypt(pwd, salt, opslimit, memlimit)
  end
end
