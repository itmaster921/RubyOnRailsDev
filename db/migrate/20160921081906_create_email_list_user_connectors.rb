class CreateEmailListUserConnectors < ActiveRecord::Migration
  def change
    create_table :email_list_user_connectors do |t|
      t.references :user, index: true, foreign_key: true
      t.references :email_list, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
