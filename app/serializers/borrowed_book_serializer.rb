class BorrowedBookSerializer < ActiveModel::Serializer
  attributes :id, :title, :available_date

  def available_date
    object.due_date.strftime('%Y-%m-%d') if object.due_date.present?
  end
end
