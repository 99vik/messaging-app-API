class CreateFriendRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :friend_requests do |t|
      t.references :sender, foreign_key: { to_table: :users }
      t.references :reciever, foreign_key: { to_table: :users }
      
      t.timestamps
    end
  end
end
