# Linux System Setup

## Install

```bash
sudo yum install -y make glibc-devel gcc patch
```

Nodejs is used for compiling handlebars and coffeescript files.

```bash
sudo apt install -y nodejs
```

```bash
sudo yum install -y nodejs
```

Make sure we have Python 3 and tools to create a virtual environment for it.

```bash
sudo apt install -y python3 python3-venv python3-pip
```

```bash
sudo yum install -y python3 python3-virtualenv python3-pip python3-devel
```

Install PostgreSQL for the database.

```bash
sudo apt install -y postgresql
```

```bash
sudo yum install -y postgresql15 postgresql15-server
```

Install Redis for caching

```bash
sudo apt install -y redis
```

```bash
sudo yum install -y redis6
```

Install Nginx for the web server

```bash
sudo apt install -y nginx-full
sudo apt install -y nginx-extras
```

```bash
sudo yum install -y nginx-add-modules
```

Install git for downloading `package_control_channel` for crawler

```bash
sudo apt install -y git
```

```bash
sudo yum install -y git
```

For development

```bash
sudo apt install -y libxml2-dev libxslt-dev libpq-dev
```

```bash
sudo yum install -y libxml2-devel libxslt-devel libpq-devel
```

## Setup

Register postgresql binary path by adding the following line to ~/.profile

```bash
if [ -d "/usr/postgresql/13/bin" ] ; then
  PATH="/usr/postgresql/13/bin:$PATH"
fi
```

Initialize the Postgres DB:

```bash
sudo /usr/bin/postgresql-setup --initdb
```

Start the Postgres DB:

```bash
sudo systemctl start postgresql.service
```

Check status after start the Postgres DB:

```bash
sudo systemctl status postgresql.service
```

Create the `package_control` database and set up all of the tables.

```bash
sudo -u postgres createdb -U postgres -E 'UTF-8' package_control
sudo -u postgres psql -U postgres -d package_control -f sql/up.sql
```

Set up the virtual environment and install the packages.

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r setup/requirements.txt
pip install -r setup/dev-requirements.txt
```

```bash
git clone --depth 1 https://github.com/wbond/package_control_channel channel
```
