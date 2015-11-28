# DB Schema in English
class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |token|
      token.text :email, :encrypted_url, :encrypted_token, :encrypted_nonce,
                 :encrypted_access_key
      token.timestamps null: false
    end
  end
end
