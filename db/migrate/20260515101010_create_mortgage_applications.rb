class CreateMortgageApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :mortgage_applications do |t|
      t.references :user, null: false, foreign_key: true
      
      t.decimal :annual_income, precision: 12, scale: 2, null: false
      t.decimal :monthly_expenses, precision: 12, scale: 2, null: false
      t.decimal :deposit_amount, precision: 12, scale: 2, null: false
      t.decimal :property_value, precision: 12, scale: 2, null: false
      t.integer :term_years, null: false
      
      t.string :status, default: 'new', null: false
      
      t.string :loan_to_value
      t.string :debt_to_income
      t.decimal :maximum_borrowing_estimate, precision: 12, scale: 2
      t.text :explanation

      t.timestamps
    end

    add_index :mortgage_applications, :status
  end
end
