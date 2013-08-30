class CommentQualifiers < ActiveRecord::Base
#  set_table_name 'comment_qualifiers'
  belongs_to :comment
  belongs_to :person

  validates_presence_of :comment, :person
end
