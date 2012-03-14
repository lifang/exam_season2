class CreateCollctionInfos < ActiveRecord::Migration
  def change
    create_table :collction_infos do |t|

      t.timestamps
    end
  end
end
