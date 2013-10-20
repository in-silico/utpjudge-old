utpjudge
========

UTP judge is an online judge created by In-silico for programming assignments and ACM-ICPC local training.

## Installation


1 - Install necesary packages.

  # apt-get install curl git sudo g++ gcc libstdc++6 sharutils openjdk-6-jdk openjdk-6-jre openjdk-7-jdk openjdk-7-jre python nodejs timelimit

2 - Install ruby and  rails

  $ \curl -L https://get.rvm.io | bash -s stable --ruby --rails
  # echo "source /usr/local/rvm/scripts/rvm" >> /etc/bash.bashrc
  $ source /etc/bash.bashrc

3 - Download the UTP Judge

  $ git clone https://github.com/in-silico/utpjudge.git

4 - Base configuration

  $ cd utpjudge/
  # ./config.sh  
  # rm Gemfile.lock
  # bundle install

5 - Capistrano 
 
   Modify the file ./config/deploy.rb to specific configuration, by default the app will be to: /var/www/apps/YOUR-SITE (Make sure that provide the necesary permissions to the user -Non root user-).

   $ bundle exec cap deploy:setup
   $ bundle exec cap deploy:check
   $ bundle exec cap deploy 
   $ bundle exec cap deploy:migrate
   $ bundle exec cap deploy:seed

6 - Config the server (apache)

6.1 Install apache

     # gem install passenger 
     # passenger-install-apache2-module

6.2 Configuration

  When the previous step is completed, you will obtain a message like this:
	"LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.2.2/ext/apache2/mod_passenger.so
	 PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.2.2
 	 PassengerRuby /usr/bin/ruby1.8"
  
  These lines must be added to file "/etc/apache2/apache2.conf"
     
  - Enable the  'mod_rewrite' for apache:
  
    #  a2enmod rewrite

  - Create the virtual host for apache in "/etc/apache2/sites-available/"
	
    # your_awesome_editor /etc/apache2/sites-available/YOUR-SITE.conf

	Example.

		<VirtualHost *:80>
		    # Change these 3 lines to suit your project
		    #RailsEnv development
		    RailsEnv production
		    ServerName 192.168.1.5 # Debe ser la ip real
		    DocumentRoot /your_path/public # Note the 'public' directory
		</VirtualHost>


  - Enable the site (Note that must have the same name that the previous file)
	
    #  a2ensite YOUR-SITE

  - Config apache to run in localhost (if is your case)
    
    # echo "ServerName localhost" >> /etc/apache2/apache2.conf

  - Restart the apache server. 
	  
    # service apache2 restart


7 - Upload the problems
