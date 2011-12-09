class CreateStudyPlans < ActiveRecord::Migration
  def change
    create_table :study_plans do |t|

      t.timestamps
    end
  end
end
