class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :load_question, only: [ :show, :destroy ]
  
  def index
    @questions = Question.all
  end
  
  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user
    if @question.save
      flash[:notice] = 'Your question successfully created.'
      redirect_to @question
    else
      render :new
    end
  end
  
  def destroy
    if current_user.author_of?(@question)
      @question.destroy
      flash[:notice] = 'Your question is deleted.'
      redirect_to questions_path
    else
      flash[:notice] = 'You are not the author.'
      render :show
    end
  end
  
  private
  
  def load_question
    @question = Question.find(params[:id])
  end
 
  def question_params
    params.require(:question).permit(:title, :body)
  end
end
