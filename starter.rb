# Create gemset
run "rvm gemset create #{app_name}"

# Add rvm files
create_file ".ruby-gemset", "#{app_name}\n"
create_file ".ruby-version", "#{RUBY_VERSION}"

# add template file paths
def source_paths
  Array(super) + 
    [File.join(File.expand_path(File.dirname(__FILE__)),'rails_root')]
end

# Add gems

gem 'haml-rails'
gem 'normalize-rails'
gem 'bourbon'
gem 'neat'
gem 'startmeup'
gem 'refills'
gem 'bluecloth'
gem 'font-awesome-rails'
gem 'devise'
gem 'simple_form'
gem 'draper'
gem 'figaro', '~> 1.0.0'
gem 'cancancan'
gem 'puma'
gem 'nav_lynx'
gem "paperclip", "~> 4.2"
gem 'aws-sdk'
gem 'sweet-alert-confirm'
gem 'kaminari'

gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'html2haml'
end

gem_group :test do
  gem "email_spec"
  gem "cucumber-rails", :require => false
  gem 'rspec-rails', '3.1'
  gem 'spring'
  gem 'simplecov'
end

gem_group :development, :test do
  gem "byebug"
  gem 'faker'
  gem "database_cleaner"
  gem 'shoulda-matchers', require: false 
  gem 'did-you-mean', '~> 0.1.1'
  gem "factory_girl_rails"
end

gem_group :production, :staging do
  gem 'rails_12factor'
end

# remove turbolinks :)
gsub_file "Gemfile", /^gem\s+["']turbolinks["'].*$/,''

# specify ruby
insert_into_file 'Gemfile', "\nruby '2.1.2'", after: "source 'https://rubygems.org'\n"

# install simpleform
run "rails generate simple_form:install"

# Install Rspec + Cucumber
run 'rails generate rspec:install'
# run 'bundle binstubs rspec-core'
run 'rails generate cucumber:install'

# config rspec
inject_into_file 'config/application.rb', :after => "class Application < Rails::Application\n" do <<-'RUBY'
  config.generators do |g|
    g.test_framework :rspec, fixture: true
    g.fixture_replacement :factory_girl, dir: 'spec/factories'
    g.view_specs false
    g.decorator_specs false
    g.helper_specs false
    g.stylesheets = false
    g.javascripts = false
    g.helper = false
  end
RUBY
end

# gsub_file ".rspec", /^\-\-warnings$/, "--format documentation\n"
# gsub_file ".rspec", /^\-\-warnings$/, '--require spec_helper'
insert_into_file '.rspec', "\n--format documentation", after: "--color"

# remove public index.html
remove_file "public/index.html"

# generate styleguide
generate "controller", "styleguides index --no-helper --no-assets --no-view-specs --no-decorator-specs"
route "root 'styleguides#index'"

# add template files
inside 'app' do
  inside 'views' do
    inside 'layouts' do
      remove_file 'application.html.erb'
      template 'application.html.haml'
    end
    inside 'shared' do
      copy_file '_footer.html.haml'
    end
  end
end

inside 'app' do
  inside 'views' do
    inside 'styleguides' do
      remove_file 'index.html.haml'
      copy_file 'index.html.haml'
    end
  end
end

inside 'app' do
  inside 'assets' do
    inside 'stylesheets' do
      run "startmeup install"
      remove_file 'application.css'
      copy_file 'application.css.sass'
      copy_file '_mixins.sass'
      copy_file '_debug.sass'
    end
  end
end

if yes?('Using PG database? (y/n)')
  inside 'config' do
    remove_file 'database.yml'
    copy_file 'database_example.yml'
  end
end

inside 'features' do
  copy_file 'styleguide.feature'
  inside 'step_definitions' do
    copy_file 'styleguide_steps.rb'
  end
end

# uncomment grid-settings sass for Neat
gsub_file 'app/assets/stylesheets/base/_base.sass', /^\/\/ @import grid-settings$/, "@import grid-settings"

# remove turbolinks from application.js
gsub_file 'app/assets/javascripts/application.js', /^\/\/\= require turbolinks$/, ""

# Add Refills
# rails generate refills:import SNIPPET

# if yes?('Install Rspec + Factory Girl? (y/n)')
  
# end

def run_bundle ; end

say <<-finished
  ============================================================================

  Your new Rails application "#{app_name}" is ready to go.
  
  Now, run 

  $ cd #{app_name}
  $ bundle

  Alter config/database_example.yml as required and run:

  $ rake db:create db:migrate

  Remember, you can now add Refills modules from Thoughtbot (https://github.com/thoughtbot/refills#installation-for-ruby-on-rails)

  ============================================================================
finished