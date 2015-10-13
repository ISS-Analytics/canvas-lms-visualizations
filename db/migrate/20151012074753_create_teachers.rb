# DB Schema in English
class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |teacher|
      teacher.text :email, :hashed_password, :salt
      teacher.timestamps null: false
    end
  end
end
