class RemovePassportFromAdmin < ActiveRecord::Migration
  def change
    remove_attachment :admins, :passport
  end
end
