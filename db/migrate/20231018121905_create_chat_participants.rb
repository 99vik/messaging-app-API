class CreateChatParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_participants do |t|
      t.references :chat
      t.references :participant, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
