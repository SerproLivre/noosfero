class CreateArticleQualifiers < ActiveRecord::Migration
  def self.up
    create_table :article_qualifiers do |t|
      t.integer :article_id
      t.integer :person_id
      t.integer :value
    end
    add_index :article_qualifiers, [:article_id, :person_id], :unique => true
  end

  def self.down
    drop_table :article_qualifiers
  end
end
