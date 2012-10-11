#encoding: utf-8
class CheckController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @user_questions=UserQuestion.paginate_by_sql("select description,id from user_questions 
        where is_answer=#{UserQuestion::IS_ANSWERED[:NO]} and  category_id=#{params[:category].to_i}
        order by created_at asc", :per_page =>10, :page => params[:page])
  end

  #删除问题
  def delete_question
    UserQuestion.find(params[:question_id].to_i).destroy
    respond_to do |format|
      format.json {
        render :json=>{}
      }
    end
  end

  #显示问题
  def show_question
    @question=UserQuestion.find(params[:question_id].to_i)
    @answers=@question.question_answers
  end

  #删除回答
  def delete_answer
    QuestionAnswer.find(params[:answer_id].to_i).destroy
    @question=UserQuestion.find(params[:question_id].to_i)
    @answers=@question.question_answers
  end
  
  #设置问题答案
  def set_answer
    question=UserQuestion.find params[:question_id].to_i
    question.update_attributes(:is_answer=>UserQuestion::IS_ANSWERED[:YES])
    answer=QuestionAnswer.find params[:answer_id].to_i
    answer.update_attributes(:is_right=>UserQuestion::IS_ANSWERED[:YES])
    Sun.create(:category_id=>question.category_id,:user_id=>answer.user_id,:types=>Sun::TYPES[:ANSWER],:num=>Sun::TYPE_NUM[:ANSWER])
    respond_to do |format|
      format.json {
        render :json=>{}
      }
    end
  end

end
