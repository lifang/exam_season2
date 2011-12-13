class CreateWordDiscriminateRelations < ActiveRecord::Migration
  def change
    create_table :word_discriminate_relations do |t|

      t.timestamps
    end
  end
end
