class CreateInviteCodes < ActiveRecord::Migration
  def change
    create_table :invite_codes do |t|

      t.timestamps
    end
  end
end
