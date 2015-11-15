# DB Schema in English
class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |token|
      token.text :email, :canvas_url, :encrypted_token, :encrypted_nonce
      token.timestamps null: false
    end
  end
end
