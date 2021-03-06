require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question_with_answers) { create(:question, :with_answers) }
  let!(:question) { create(:question) }
  
  describe 'POST #create' do
    sign_in_user
    
    context 'with valid attributes' do
      it 'saves a new answer in the database' do
        expect { post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js }.to change(question.answers, :count).by(1)
      end
      
      it 'render template create' do
        post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js
        expect(response).to render_template :create
      end
      
      it 'check current_user is author' do 
        post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js
        expect(assigns(:answer).user).to eq @user
      end
    end
    
    context 'with invalid attributes' do
      it 'does not save the answer' do
        expect { post :create, params: { answer: attributes_for(:invalid_answer), question_id: question }, format: :js }.to_not change(Answer, :count)
      end
      
      it 're-render new view' do
        post :create, params: { answer: attributes_for(:invalid_answer), question_id: question }, format: :js
        expect(response).to render_template :create
      end
    end
  end
  
  describe 'DELETE #destroy' do
    let(:answer) { question_with_answers.answers.first }
    context 'users answer' do
      sign_in_user
      before { answer.update(user_id: @user.id) }
      
      it 'deletes answer' do 
        expect { delete :destroy, params: { question_id: question_with_answers, id: answer, format: :js } }.to change(Answer, :count).by(-1) 
      end

      it 'redirect to parent question show' do 
        delete :destroy, params: { question_id: question_with_answers, id: answer, format: :js }
        expect(response).to render_template :destroy
      end
    end
    
    context 'not users answer' do
      sign_in_user
      before { question_with_answers }

      it 'deletes answer' do 
        expect { delete :destroy, params: { question_id: question_with_answers, id: answer, format: :js } }.to_not change(Answer, :count)
      end

      it 'redirect to parent question show' do 
        delete :destroy, params: { question_id: question_with_answers, id: answer, format: :js }
        expect(response).to render_template :destroy
      end
    end
  end
  
  describe 'patch #UPDATE' do
    sign_in_user
    let(:answer) { create(:answer, question: question, user: @user) }
    
    it 'assigns the requested answer to @answer' do
      patch :update, params: { id: answer, question_id: question, answer: attributes_for(:answer), format: :js }
      expect(assigns(:answer)).to eq answer
    end
    
    it 'assigns the requested question for @question' do
      patch :update, params: { id: answer, question_id: question, answer: attributes_for(:answer), format: :js }
      expect(assigns(:question)).to eq question
    end
    
    it 'changes answer attributes' do
      patch :update, params: { id: answer, question_id: question, answer: {body: 'New body'}, format: :js }
      answer.reload
      expect(answer.body).to eq 'New body'
    end
    
    it 'render update template' do
      patch :update, params: { id: answer, question_id: question, answer: attributes_for(:answer), format: :js }
      expect(response).to render_template :update
    end
  end
  
  describe 'PATCH #favorite' do
    sign_in_user
    let(:question_of_author) { create(:question, user: @user) }
    let(:answer) { create(:answer, question: question, user: @user) }
    
    it 'assigns the requested question and answer' do
      patch :favorite, params: { id: answer, question_id: question, format: :js }
      expect(assigns(:question)).to eq question
      expect(assigns(:answer)).to eq answer
    end
    
    it 'Author of question try to choose favorite' do
      patch :favorite, params: { id: answer, question_id: question_of_author, format: :js }
      answer.reload
      expect( answer.is_favorite ).to eq true
    end
    
    it 'Any user try to choose favorite' do
      expect { patch :favorite, params: { id: answer, question_id: question, format: :js } }.to_not change(answer, :is_favorite)
    end
  end
  
  describe 'PATCH #vote_up' do 
    sign_in_user
    let(:answer) { create(:answer) }
    context 'non author try to vote up' do 
      context 'user already has vote' do 
        before do 
          create(:vote, :up, user: @user, votable: answer)
          answer.update(question: question)
        end

        it 'dont change votes' do 
          expect{ patch :vote_up, params: { question_id: question, id: answer } }.to_not change(answer.votes, :count)
        end

        it 'render error' do 
          patch :vote_up, params: { question_id: question, id: answer }
          expect(response.body).to eq 'You already voted'
        end

        it 'response error 422' do 
          patch :vote_up, params: { question_id: question, id: answer }
          expect(response).to have_http_status(422)
        end
      end
    end

    context 'answer author try to vote up' do 
      before { answer.update(user: @user, question: question) }
      it 'dont change votes' do 
        expect{ patch :vote_up, params: {question_id: question,  id: answer } }.to_not change(answer.votes, :count)
      end

      it 'response error 422' do 
        patch :vote_up, params: { question_id: question, id: answer }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH #vote_down' do 
    sign_in_user
    let(:answer) { create(:answer) }
    context 'non author try to vote down' do 
      context 'user already has vote' do 
        before do 
          create(:vote, :down, user: @user, votable: answer)
          answer.update(question: question)
        end

        it 'dont change votes' do 
          expect{ patch :vote_down, params: { question_id: question, id: answer } }.to_not change(answer.votes, :count)
        end

        it 'render error' do 
          patch :vote_down, params: { question_id: question, id: answer }
          expect(response.body).to eq 'You already voted'
        end

        it 'response error 422' do 
          patch :vote_down, params: { question_id: question, id: answer }
          expect(response).to have_http_status(422)
        end
      end
    end

    context 'answer author try to vote down' do 
      before { answer.update(user: @user, question: question) }

      it 'dont change votes' do 
        expect{ patch :vote_down, params: {question_id: question,  id: answer } }.to_not change(answer.votes, :count)
      end

      it 'response error 422' do 
        patch :vote_down, params: { question_id: question, id: answer }
        expect(response).to have_http_status(422)
      end
    end
  end
end
