require_dependency 'comment'

class Comment

  has_many :read_comments, :class_name => 'MarkCommentAsReadPlugin::ReadComments'
  has_many :people, :through => :read_comments
#  has_and_belongs_to_many :users, :through => :mark_comment_as_read_plugin_read_comments

  def mark_as_read(person)
    people << person
  end

  def mark_as_not_read(person)
    people.delete(person)
  end

  def marked_as_read?(person)
    people.find(:first, :conditions => {:id => person.id})
  end
end
