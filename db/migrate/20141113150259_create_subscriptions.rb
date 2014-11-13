class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :mailer_id
      t.string :email
      t.string :token

      t.timestamps
    end
    add_index :subscriptions, :mailer_id
  end
end
