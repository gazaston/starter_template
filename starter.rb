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
  gem 'rspec-rails', '~> 3.0.0'
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

# add template file paths
def source_paths
  Array(super) + 
    [File.join(File.expand_path(File.dirname(__FILE__)),'rails_root')]
end

# remove public index.html
remove_file "public/index.html"

# generate styleguide
run "rails generate controller styleguides index"
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

# uncomment grid-settings sass for Neat
gsub_file 'app/assets/stylesheets/base/_base.sass', /^\/\/ @import grid-settings$/, "@import grid-settings"

# remove turbolinks from application.js
gsub_file 'app/assets/javascripts/application.js', /^\/\/\= require turbolinks$/, ""

# Add Refills
# rails generate refills:import SNIPPET