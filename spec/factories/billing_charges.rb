# == Schema Information
#
# Table name: billing_charges
#
#  id             :integer          not null, primary key
#  uid            :string(50)
#  user_id        :integer
#  payment_method :integer          default(0)
#  status         :integer          default(0)
#  currency       :string(5)
#  amount         :decimal(, )
#  tax            :decimal(, )
#  tax_percentage :decimal(, )
#  description    :string
#  details        :hstore
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_billing_charges_on_user_id  (user_id)
#

FactoryGirl.define do
  factory :billing_charge, :class => 'Billing::Charge' do
    uid "MyString"
user nil
payment_type 1
status 1
amount "9.99"
tax "9.99"
tax_percentage "9.99"
description "MyString"
details ""
  end

end
