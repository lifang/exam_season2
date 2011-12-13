class CreateDiscriminates < ActiveRecord::Migration
  def change
    create_table :discriminates do |t|

      t.timestamps
    end
  end
end
