class CreateCommentQualifiers < ActiveRecord::Migration
  def self.up
    create_table :comment_qualifiers do |t|
      t.integer :comment_id
      t.integer :person_id
      t.integer :value
    end
    add_index :comment_qualifiers, [:comment_id, :person_id], :unique => true
  end

  def self.down
    drop_table :comment_qualifiers
  end
end
