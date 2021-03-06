#!/usr/bin/env bash

# Hide the stdin is not a tty garbage...
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

export DEBIAN_FRONTEND=noninteractive

echo 'Updating APT...'
sudo apt-get -y update > /dev/null 2>&1

echo 'Installing git, curl, build-essential, libssl-dev, libreadline-dev...'
sudo apt-get -y install git curl build-essential libssl-dev libreadline-dev > /dev/null 2>&1

# Install rbenv
echo 'Installing rbenv...'
sudo -u vagrant git clone git://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
sudo -u vagrant echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.profile
sudo -u vagrant echo 'eval "$(rbenv init -)"' >> /home/vagrant/.profile
sudo -u vagrant git clone git://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build

sudo -u vagrant -i rbenv install 2.2.2
sudo -u vagrant -i rbenv global 2.2.2

# Sanity check
sudo -u vagrant -i ruby -v

# Install Postgres
echo 'Installing Postgres...'
sudo apt-get -y install postgresql-9.1 libpq-dev > /dev/null 2>&1

sudo -u postgres psql -c "CREATE USER wecrowd WITH PASSWORD 'wecrowd';"
sudo -u postgres psql -c "CREATE DATABASE wecrowd OWNER wecrowd;"

# Install Node.js
echo 'Installing Node.js'
curl -sL https://deb.nodesource.com/setup_0.10 | sudo bash -
sudo apt-get -y install nodejs > /dev/null 2>&1

# Update Gems
echo 'Updating gems...'
sudo -u vagrant -i gem update --system --no-document > /dev/null 2>&1

echo "Install project gems..."
sudo -u vagrant -i gem install bundler --no-document
sudo -u vagrant -i bundle install --gemfile=/vagrant/Gemfile
cd /vagrant && sudo -u vagrant -i bundle update rake
sudo -u vagrant echo 'export PORT=3000' >> /home/vagrant/.profile
sudo -u vagrant echo 'export RAILS_ENV=development' >> /home/vagrant/.profile

echo "Running migrations..."
sudo -u vagrant -i rake -f /vagrant/Rakefile db:migrate
sudo -u vagrant -i rake -f /vagrant/Rakefile db:seed

echo 'Precompiling the static assets'
sudo -u vagrant -i rake -f /vagrant/Rakefile assets:precompile

# echo 'Starting rails'
# cd '/vagrant'
# sudo -u vagrant -i rails server

echo "cd /vagrant" | sudo tee /etc/profile.d/cd-vagrant.sh
