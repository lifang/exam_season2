class CreateUserActionLogs < ActiveRecord::Migration
  def change
    create_table :user_action_logs do |t|

      t.timestamps
    end
  end
end
