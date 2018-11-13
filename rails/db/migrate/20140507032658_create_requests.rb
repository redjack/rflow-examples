class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.text :data
      t.timestamps null: false
    end
  end
end
