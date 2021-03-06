# == Schema Information
#
# Table name: subjects
#
#  id            :integer          not null, primary key
#  name          :string(50)
#  row           :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  time_estimate :string(50)
#  excerpt       :string
#  description   :string
#  slug          :string
#  published     :boolean
#

require 'rails_helper'

RSpec.describe Subject, type: :model do

  context 'associations' do
    it { should have_many(:resources) }
    it { should have_many(:challenges) }
    it { should have_many(:badges).dependent(:destroy) }
  end

  context 'validations' do
    it { should validate_presence_of :name }
  end

  it "has a valid factory" do
    expect(build(:subject)).to be_valid
  end

  context "friendly_id" do
    it "should update the slug after updating the name" do
      subject = create(:subject)

      # change the name of the subject
      subject.name = "a random name"
      subject.save

      expect(subject.slug).to eq("a-random-name")
      expect(subject.slug).to eq(subject.friendly_id)
    end
  end
end
