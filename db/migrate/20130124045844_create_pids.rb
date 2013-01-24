class CreatePids < ActiveRecord::Migration
  def self.up
    create_table :pids do |t|
      t.string :code
      t.string :key
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pids
  end
end
