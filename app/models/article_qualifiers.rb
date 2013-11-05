class ArticleQualifiers < ActiveRecord::Base
  belongs_to :article
  belongs_to :person

  validates_presence_of :article, :person
end
