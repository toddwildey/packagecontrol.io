rm -Rf app/lib/package_control/deps/oscrypto
cp -Rp ../oscrypto/oscrypto app/lib/package_control/deps/

sudo yum install -y tmux
sudo yum install -y make glibc-devel gcc patch
sudo yum install -y nodejs
sudo yum install -y python3 python3-virtualenv python3-pip python3-devel
sudo yum install -y postgresql15 postgresql15-server
sudo yum install -y redis6
sudo yum install -y nginx-add-modules
sudo yum install -y git
sudo yum install -y libxml2-devel libxslt-devel libpq-devel
sudo yum install -y cronie

sudo systemctl enable crond.service
sudo systemctl start crond.service
sudo systemctl status crond.service

git clone https://github.com/toddwildey/packagecontrol.io.git
cd packagecontrol.io

sudo /usr/bin/postgresql-setup --initdb
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service
sudo systemctl restart postgresql.service
sudo systemctl status postgresql.service

# So postgres can access packagecontrol.io
chmod 0755 "$HOME"

# Update pg_hba.conf with the following line
sudo nano /var/lib/pgsql/data/pg_hba.conf

# host    package_control postgres        127.0.0.1/32            scram-sha-256

sudo -u postgres psql -U postgres -d postgres -c "DROP DATABASE package_control;"
sudo -u postgres createdb -U postgres -E 'UTF-8' package_control
sudo -u postgres psql -U postgres -d package_control -f setup/sql/up.sql
sudo -u postgres psql -U postgres -d package_control -c "ALTER USER postgres WITH PASSWORD 'test';"

# Testing the pasword afterwards
sudo -u postgres psql -U postgres -d package_control -h 127.0.0.1 -W

python3 -m venv venv
source venv/bin/activate
pip install -r setup/requirements.txt

# Run locally to copy secrets to host
scp secrets.yml ec2-user@stpc:/var/www/packagecontrol.io
scp config/db.yml ec2-user@stpc:/var/www/packagecontrol.io/config

# Start server
mkdir -p assets
python dev.py

# Start building channel.json
source venv/bin/activate
python tasks.py generate_channel_json
python tasks.py generate_channel_v3_json
python tasks.py generate_channel_v4_json

# Start crawling packages
git clone https://github.com/wbond/package_control_channel.git channel
python tasks.py crawl 2>&1 | tee crawl.log

# Install crontab
crontab crontab
crontab -l
crontab -r

# Copy SSH key for stpc host
scp -p dsk:/home/$USER/.ssh/config ~/.ssh
scp -p dsk:/home/$USER/.ssh/id_ed25519-sublime-text-package-control ~/.ssh

# Run locally to copy code changes to stpc host
rsync -avz app/ ec2-user@stpc:/var/www/packagecontrol.io/app/

# Run locally to get logs from 
scp ec2-user@stpc:/var/www/packagecontrol.io/crawl.log .
