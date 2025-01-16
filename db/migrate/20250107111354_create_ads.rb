class CreateAds < ActiveRecord::Migration[7.0]
  def change
    create_table :ads do |t|
      t.integer :campaign_id
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
