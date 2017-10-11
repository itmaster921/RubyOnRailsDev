class AddPassportToAdmin < ActiveRecord::Migration
  def up
    add_attachment :admins, :passport
  end

  def down
    remove_attachment :admins, :passport
  end
end
