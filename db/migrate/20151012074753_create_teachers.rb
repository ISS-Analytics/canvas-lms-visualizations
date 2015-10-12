# DB Schema in English
class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |teacher|
      teacher.text :encrypted_fullname, :hashed_password, :email, :nonce, :salt
      teacher.timestamps null: false
    end
  end
end
