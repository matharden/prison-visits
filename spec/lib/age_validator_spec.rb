require 'rails_helper'

RSpec.describe AgeValidator do
  let :adult do
    Visitor.new(date_of_birth: (Date.today - 18.years))
  end

  let :young_adult do
    Visitor.new(date_of_birth: (Date.today - 16.years))
  end

  context "a regular prison" do
    subject do
      AgeValidator.new(Rails.configuration.prison_data['Cardiff'])
    end

    it "considers an 18-year old person to be an adult" do
      subject.validate(adult)
      expect(adult.errors[:date_of_birth]).to be_empty
      subject.validate(young_adult)
      expect(young_adult.errors[:date_of_birth]).not_to be_empty
    end
  end

  context "a prison which treats a child above a certain age as an adult" do
    subject do
      AgeValidator.new(Rails.configuration.prison_data['Werrington'])
    end

    it "considers a 16-year old to be an adult" do
      subject.validate(adult)
      expect(adult.errors[:date_of_birth]).to be_empty
      subject.validate(young_adult)
      expect(young_adult.errors[:date_of_birth]).to be_empty
    end
  end
end
