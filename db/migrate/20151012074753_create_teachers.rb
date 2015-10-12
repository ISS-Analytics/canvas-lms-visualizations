# DB Schema in English
class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |teacher|
      teacher.text :username, :email, :hashed_password, :nonce, :salt
      teacher.timestamps null: false
    end
  end
end
