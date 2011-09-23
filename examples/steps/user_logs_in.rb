class UserLogsIn < Spinach::Feature
  feature "User logs in"

  Given 'I am not logged in' do
    123
  end

  When 'I log in' do
    @a = 'hey'
  end

  Then 'I should be logged in' do
    @a.must_equal 'heyo'
  end
end

