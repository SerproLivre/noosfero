class CreateLikedComments < ActiveRecord::Migration
  def self.up
    create_table :liked_comments do |t|
      t.integer :comment_id
      t.integer :person_id
      t.integer :value
    end
    add_index :liked_comments, [:comment_id, :person_id], :unique => true
  end

  def self.down
    drop_table :liked_comments
  end
end
