# DB Schema in English
class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |token|
      token.text :email, :encrypted_token, :nonce
      token.timestamps null: false
    end
  end
end
