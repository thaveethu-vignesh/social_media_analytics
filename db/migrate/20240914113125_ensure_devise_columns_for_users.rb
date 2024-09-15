class EnsureDeviseColumnsForUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users do |t|
      t.string :encrypted_password, null: false, default: "" unless column_exists?(:users, :encrypted_password)
      t.string   :reset_password_token unless column_exists?(:users, :reset_password_token)
      t.datetime :reset_password_sent_at unless column_exists?(:users, :reset_password_sent_at)
      t.datetime :remember_created_at unless column_exists?(:users, :remember_created_at)
      
      # Add any other Devise columns you need here
    end
    
    unless index_exists?(:users, :email)
      add_index :users, :email, unique: true
    end
    
    unless index_exists?(:users, :reset_password_token)
      add_index :users, :reset_password_token, unique: true
    end
  end
end