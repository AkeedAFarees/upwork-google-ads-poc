class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :google_token
      t.string :google_refresh_token
      t.datetime :google_expires_at
      t.string :google_customer_id

      t.timestamps
    end
  end
end
