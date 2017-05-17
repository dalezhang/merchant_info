require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
require 'mina/rvm'    # for rvm support. (https://rvm.io)
require 'securerandom'


# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

app_name = 'merchant_info'

set :application_name, app_name
set :domain, 'rb@119.23.200.62'
set :deploy_to, "/home/rb/prgs/#{app_name}"
set :repository, "git@git.coding.net:pgate/#{app_name}.git"
set :branch, 'deploy'

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# set :shared_dirs, fetch(:shared_dirs, []).push('somedir')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml', 'config/puma.rb')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  puts "rvm:use"
  invoke :'rvm:use', 'ruby-2.3.4'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
  in_path './prgs' do
    command %{pwd}
    command %{cp -R shared/config #{fetch(:deploy_to)}/shared}
    command %{sed -i 's/SECRET/#{SecureRandom.hex(64)}/g' #{fetch(:deploy_to)}/shared/config/secrets.yml}
    command %{sed -i '1s/APP_NAME/#{app_name}/1' #{fetch(:deploy_to)}/shared/config/puma.rb}
  end
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
		invoke :clean_shared_files
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'


    on :launch do
      in_path("/home/rb") do
        invoke :environment
        command %{source .bashrc}
        #command %{rails s -e production}
        command %{ ruby -v }
        command %{ ls /home/rb/prgs/merchant_info/current}
        command %{ ls /home/rb/tmp/pids/}
        command %{ eye restart merchant_info}
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end
task :clean_shared_files do
  command %{rm config/database.yml config/puma.rb config/secrets.yml}
end
task :eye do
  command %{ pwd }
  invoke :environment
  command %{ rvm -v }
  command %{ ruby -v }
  command %{eye i}
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
