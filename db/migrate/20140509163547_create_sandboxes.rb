class CreateSandboxes < ActiveRecord::Migration
  def change
    create_table :sandboxes do |t|
      t.integer :page_id
      t.string :uuid
      t.text :attrs

      t.timestamps
    end
  end
end
