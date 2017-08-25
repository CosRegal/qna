class AnswersController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :load_answer, only: [ :destroy ]
  before_action :load_question, only: [ :create, :destroy ]
  
  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user
    if @answer.save
      flash[:notice] = 'Your answer successfully created.'
      redirect_to question_path(@question)
    else
      flash[:notice] = 'Your answer is not create.'
      render 'questions/show'
    end
    
  end
  
  def destroy
    if current_user.author_of?(@answer)
      @answer.destroy
      flash[:notice] = 'Your answer is deleted.'
    else
      flash[:notice] = 'You are not the author.'
    end
    redirect_to question_path(@question)
  end
  
  private
  
  def load_answer
    @answer = Answer.find(params[:id])
  end
  
  def load_question
    @question = Question.find(params[:question_id])
  end
  
  def answer_params
    params.require(:answer).permit(:title, :body)
  end
end
