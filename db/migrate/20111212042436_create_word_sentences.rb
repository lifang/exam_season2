class CreateWordSentences < ActiveRecord::Migration
  def change
    create_table :word_sentences do |t|

      t.timestamps
    end
  end
end
