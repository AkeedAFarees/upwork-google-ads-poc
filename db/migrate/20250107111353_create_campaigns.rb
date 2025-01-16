class CreateCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns do |t|
      t.integer :user_id
      t.string :name
      t.integer :budget
      t.string :status

      t.timestamps
    end
  end
end
