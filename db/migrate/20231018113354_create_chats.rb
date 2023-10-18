class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.string :name
      t.string :type
      t.references :admin, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
