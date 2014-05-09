class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.integer :sandbox_id
      t.string :uuid
      t.text :attrs

      t.timestamps
    end
  end
end
