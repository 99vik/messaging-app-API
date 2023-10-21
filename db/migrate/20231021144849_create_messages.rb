class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.string :body
      t.references :chat
      t.references :user

      t.timestamps
    end
  end
end
