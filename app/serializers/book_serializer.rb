class BookSerializer < ActiveModel::Serializer
  attributes :id, :title, :author, :genre, :isbn, :available_copies, :status

  def status
    object.available_copies > 0 ? 'available' : 'borrowed'
  end
end
