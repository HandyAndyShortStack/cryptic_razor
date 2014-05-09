class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.integer :user_id
      t.string :subdomain
      t.text :attrs

      t.timestamps
    end
  end
end
