Given(/^I have created an app from the template$/) do
  visit root_path
  page.has_css?('title', text: "#{@app_name}")
end

Then(/^I should see the styleguide$/) do
  page.has_css?('h1', text: 'Styleguide')
end
