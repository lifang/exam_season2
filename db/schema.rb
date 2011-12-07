# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111129054018) do

  create_table "action_logs", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "types"
    t.integer  "category_id"
    t.string   "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_num"
  end

  add_index "action_logs", ["category_id"], :name => "index_action_logs_on_category_id"
  add_index "action_logs", ["types"], :name => "index_action_logs_on_type"
  add_index "action_logs", ["user_id"], :name => "index_action_logs_on_user_id"

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
    t.integer "price"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"
  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "category_manages", :force => true do |t|
    t.integer  "category_id", :null => false
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "category_manages", ["category_id"], :name => "index_category_manages_on_category_id"
  add_index "category_manages", ["user_id"], :name => "index_category_manages_on_user_id"

  create_table "charts", :force => true do |t|
    t.integer  "types"
    t.datetime "created_at"
    t.string   "image_url"
  end

  create_table "collections", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.string   "collection_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collections", ["user_id"], :name => "index_collections_on_user_id"

  create_table "competes", :force => true do |t|
    t.integer "user_id"
    t.date    "created_at"
    t.integer "price"
    t.string  "remark"
  end

  add_index "competes", ["user_id"], :name => "index_competes_on_user_id"

  create_table "courses", :force => true do |t|
    t.string "title"
    t.text   "description"
    t.date   "created_at"
  end

  add_index "courses", ["title"], :name => "index_courses_on_title"

  create_table "exam_raters", :force => true do |t|
    t.datetime "created_at"
    t.string   "name"
    t.string   "mobilephone"
    t.string   "email"
    t.string   "author_code"
    t.integer  "examination_id"
  end

  add_index "exam_raters", ["author_code"], :name => "index_exam_raters_on_author_code"
  add_index "exam_raters", ["examination_id"], :name => "index_exam_raters_on_examination_id"

  create_table "exam_users", :force => true do |t|
    t.integer  "examination_id"
    t.integer  "user_id"
    t.string   "password"
    t.datetime "created_at"
    t.integer  "paper_id"
    t.datetime "started_at"
    t.datetime "submited_at"
    t.datetime "ended_at"
    t.boolean  "is_submited"
    t.boolean  "open_to_user"
    t.string   "answer_sheet_url"
    t.boolean  "is_user_affiremed"
    t.integer  "total_score"
    t.boolean  "is_auto_rate",      :default => false
    t.boolean  "is_free"
    t.integer  "correct_percent"
    t.string   "rank"
  end

  add_index "exam_users", ["examination_id"], :name => "index_exam_users_on_examination_id"
  add_index "exam_users", ["paper_id"], :name => "index_exam_users_on_paper_id"
  add_index "exam_users", ["user_id"], :name => "index_exam_users_on_user_id"

  create_table "examination_paper_relations", :force => true do |t|
    t.integer "examination_id"
    t.integer "paper_id"
  end

  add_index "examination_paper_relations", ["examination_id"], :name => "index_examination_paper_relations_on_examination_id"
  add_index "examination_paper_relations", ["paper_id"], :name => "index_examination_paper_relations_on_paper_id"

  create_table "examinations", :force => true do |t|
    t.string   "title"
    t.integer  "creater_id"
    t.string   "description"
    t.boolean  "is_score_open"
    t.boolean  "is_paper_open"
    t.string   "exam_password1"
    t.string   "exam_password2"
    t.datetime "start_at_time"
    t.datetime "start_end_time"
    t.integer  "exam_time"
    t.boolean  "is_published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "user_affirm"
    t.integer  "status"
    t.integer  "price"
    t.datetime "get_free_end_at"
    t.datetime "exam_free_end_at"
    t.integer  "category_id"
    t.boolean  "is_should_rate"
    t.integer  "types"
    t.boolean  "is_free"
  end

  add_index "examinations", ["creater_id"], :name => "index_examinations_on_creater_id"
  add_index "examinations", ["is_paper_open"], :name => "index_examinations_on_is_paper_open"
  add_index "examinations", ["is_score_open"], :name => "index_examinations_on_is_score_open"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "status"
    t.text     "description"
    t.string   "answer"
    t.datetime "created_at"
    t.integer  "question_id"
  end

  add_index "feedbacks", ["status"], :name => "index_feedbacks_on_status"
  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id"

  create_table "model_roles", :force => true do |t|
    t.integer "role_id"
    t.integer "right_sum"
  end

  create_table "notes", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "note_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "types"
    t.integer  "total_price"
    t.string   "remark"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "status"
    t.datetime "created_at"
    t.string   "out_trade_no"
    t.integer  "pay_type"
    t.integer  "category_id"
  end

  create_table "paper_blocks", :force => true do |t|
    t.integer  "paper_id"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time"
    t.datetime "start_time"
  end

  add_index "paper_blocks", ["paper_id"], :name => "index_paper_blocks_on_paper_id"

  create_table "papers", :force => true do |t|
    t.integer  "category_id"
    t.string   "title"
    t.integer  "creater_id"
    t.string   "description"
    t.integer  "total_score"
    t.integer  "total_question_num"
    t.boolean  "is_used"
    t.string   "paper_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "paper_js_url"
    t.integer  "types"
  end

  add_index "papers", ["category_id"], :name => "index_papers_on_category_id"
  add_index "papers", ["types"], :name => "index_papers_on_types"

  create_table "problem_tag_relations", :force => true do |t|
    t.integer "tag_id"
    t.integer "problem_id"
  end

  add_index "problem_tag_relations", ["problem_id"], :name => "index_problem_tag_relations_on_problem_id"
  add_index "problem_tag_relations", ["tag_id"], :name => "index_problem_tag_relations_on_tag_id"

  create_table "problem_tags", :force => true do |t|
    t.integer "problem_id"
    t.integer "total_num"
  end

  add_index "problem_tags", ["problem_id"], :name => "index_problem_tags_on_problem_id"

  create_table "problems", :force => true do |t|
    t.integer  "category_id"
    t.text     "title"
    t.integer  "types"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "complete_title"
    t.integer  "status"
    t.integer  "question_type"
  end

  add_index "problems", ["category_id"], :name => "index_problems_on_category_id"
  add_index "problems", ["question_type"], :name => "index_problems_on_question_type"
  add_index "problems", ["status"], :name => "index_problems_on_status"
  add_index "problems", ["types"], :name => "index_problems_on_types"

  create_table "proofs", :force => true do |t|
    t.string  "text"
    t.integer "user_id", :null => false
    t.boolean "checked"
  end

  create_table "question_tag_relations", :force => true do |t|
    t.integer "tag_id"
    t.integer "question_id"
  end

  add_index "question_tag_relations", ["question_id"], :name => "index_question_tag_relations_on_question_id"
  add_index "question_tag_relations", ["tag_id"], :name => "index_question_tag_relations_on_tag_id"

  create_table "questions", :force => true do |t|
    t.integer "problem_id"
    t.string  "description"
    t.string  "answer"
    t.integer "correct_type"
    t.text    "analysis"
    t.string  "question_attrs"
  end

  add_index "questions", ["correct_type"], :name => "index_questions_on_correct_type"
  add_index "questions", ["problem_id"], :name => "index_questions_on_problem_id"

  create_table "rater_user_relations", :force => true do |t|
    t.integer  "exam_user_id"
    t.integer  "exam_rater_id"
    t.boolean  "is_marked"
    t.boolean  "is_authed",     :default => false
    t.datetime "started_at"
    t.integer  "rate_time"
    t.boolean  "is_checked",    :default => false
  end

  add_index "rater_user_relations", ["exam_rater_id"], :name => "index_rater_user_relations_on_exam_rater_id"
  add_index "rater_user_relations", ["exam_user_id"], :name => "index_rater_user_relations_on_exam_user_id"
  add_index "rater_user_relations", ["is_marked"], :name => "index_rater_user_relations_on_is_marked"

  create_table "report_errors", :force => true do |t|
    t.integer  "paper_id"
    t.string   "paper_title"
    t.integer  "user_id"
    t.string   "user_name"
    t.integer  "error_type"
    t.integer  "question_index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "score_levels", :force => true do |t|
    t.integer "examination_id"
    t.string  "key"
    t.string  "value"
  end

  add_index "score_levels", ["examination_id"], :name => "index_score_levels_on_examination_id"
  add_index "score_levels", ["key"], :name => "index_score_levels_on_key"

  create_table "statistics", :force => true do |t|
    t.datetime "created_at"
    t.integer  "register_num"
    t.integer  "action_num"
    t.integer  "pay_num"
    t.integer  "money_num"
  end

  add_index "statistics", ["created_at"], :name => "index_statistic_datas_on_created_at"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "num",  :default => 0
  end

  create_table "user_action_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "total_num"
    t.integer  "week_num"
    t.datetime "last_update_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_action_logs", ["user_id"], :name => "index_user_action_logs_on_user_id"

  create_table "user_beliefs", :force => true do |t|
    t.integer "user_id"
    t.date    "created_at"
    t.integer "belief"
  end

  add_index "user_beliefs", ["user_id"], :name => "index_user_beliefs_on_user_id"

  create_table "user_role_relations", :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "user_role_relations", ["role_id"], :name => "index_user_role_relations_on_role_id"
  add_index "user_role_relations", ["user_id"], :name => "index_user_role_relations_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "mobilephone"
    t.string   "email"
    t.string   "address"
    t.string   "salt"
    t.string   "encrypted_password"
    t.integer  "status"
    t.string   "active_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "school"
    t.integer  "code_id"
    t.string   "code_type"
    t.string   "belief_url"
    t.string   "open_id",            :limit => 40
  end

  add_index "users", ["code_id"], :name => "index_users_on_code_id"
  add_index "users", ["code_type"], :name => "index_users_on_code_type"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["status"], :name => "index_users_on_status"

end
