class CreatePlanTasks < ActiveRecord::Migration
  def change
    create_table :plan_tasks do |t|

      t.timestamps
    end
  end
end
