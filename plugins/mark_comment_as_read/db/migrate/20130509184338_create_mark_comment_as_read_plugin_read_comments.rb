class CreateMarkCommentAsReadPluginReadComments < ActiveRecord::Migration
  def self.up
    create_table :mark_comment_as_read_plugin_read_comments, :id => false do |t|
      t.integer :comment_id
      t.integer :person_id
    end
    add_index :mark_comment_as_read_plugin_read_comments, [:comment_id, :person_id], :unique => true
  end

  def self.down
    drop_table :mark_comment_as_read_plugin_read_comments
  end
end
