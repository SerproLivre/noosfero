class MarkCommentAsReadPlugin::ReadComments < Noosfero::Plugin::ActiveRecord
  belongs_to :comment
  belongs_to :person

  validates_presence_of :comment, :person
end
