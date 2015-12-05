require_relative '../helpers/model_helpers'

# Class for Canvas teachers
class Teacher < ActiveRecord::Base
  include ModelHelper

  validates :email, presence: true, uniqueness: true, format: /@/
  # validates :hashed_password, presence: true

  attr_accessible :email

  def password=(new_password)
    salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    tsalt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    digest_size = 64
    digest = self.class.hash_password(salt, new_password, digest_size)
    self.salt = base_64_encode(salt)
    self.token_salt = base_64_encode(tsalt)
    self.hashed_password = base_64_encode(digest)
  end

  def self.authenticate!(email, login_password)
    teacher = Teacher.find_by_email(email)
    teacher && teacher.password_matches?(login_password) ? teacher : nil
  end

  def self.token_key(pass, tsalt)
    digest_size = 24
    hash_password(tsalt, pass, digest_size)
  end

  def password_matches?(try_password)
    salt = base_64_decode(self.salt)
    size = 64
    attempted_password = self.class.hash_password(salt, try_password, size)
    hashed_password == base_64_encode(attempted_password)
  end

  def self.hash_password(salt, pwd, digest_size)
    opslimit = 2**20
    memlimit = 2**24
    RbNaCl::PasswordHash.scrypt(pwd, salt, opslimit, memlimit, digest_size)
  end
end
