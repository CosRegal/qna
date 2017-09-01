require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should validate_presence_of :body}
  it { should validate_length_of(:body).is_at_most(255) }
  it { should belong_to(:question) }
  
  context 'Mark answer to favorite' do
    let(:question_with_answers) { create(:question, :with_answers) }
    
    it 'check funtion' do
      answer = question_with_answers.answers.first
      answer.set_favorite
      
      expect(answer.is_favorite?).to eq true
    end
  end
end
