FactoryBot.define do
  factory :mortgage_application do
    user { nil }
    annual_income { "9.99" }
    monthly_expenses { "9.99" }
    deposit_amount { "9.99" }
    property_value { "9.99" }
    term_years { 1 }
    status { "MyString" }
    loan_to_value { "MyString" }
    debt_to_income { "MyString" }
    maximum_borrowing_estimate { "9.99" }
    explanation { "MyText" }
  end
end
