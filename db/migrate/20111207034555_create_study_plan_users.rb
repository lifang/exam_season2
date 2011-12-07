class CreateStudyPlanUsers < ActiveRecord::Migration
  def change
    create_table :study_plan_users do |t|

      t.timestamps
    end
  end
end
