class LikeCommentPlugin::LikedComments < Noosfero::Plugin::ActiveRecord
  set_table_name 'liked_comments'
  belongs_to :comment
  belongs_to :person

  validates_presence_of :comment, :person
end
