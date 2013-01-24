class AddPidIdToMessagesTable < ActiveRecord::Migration
  def self.up
    add_column :messages,:pid_id,:integer
  end

  def self.down
    remove_column :messages,:pid_id
  end
end
