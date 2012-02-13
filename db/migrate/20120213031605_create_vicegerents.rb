class CreateVicegerents < ActiveRecord::Migration
  def change
    create_table :vicegerents do |t|

      t.timestamps
    end
  end
end
