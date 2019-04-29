[![Build Status](https://travis-ci.org/mumuki/mumuki-python-runner.svg?branch=master)](https://travis-ci.org/mumuki/mumuki-python-runner)
[![Code Climate](https://codeclimate.com/github/mumuki/mumuki-python-runner/badges/gpa.svg)](https://codeclimate.com/github/mumuki/mumuki-python-runner)
[![Test Coverage](https://codeclimate.com/github/mumuki/mumuki-python-runner/badges/coverage.svg)](https://codeclimate.com/github/mumuki/mumuki-python-runner)

# Install the server

## Clone the project

```
git clone https://github.com/mumuki/mumuki-python-runner
cd mumuki-python-runner
```

## Install global dependencies

```bash
rbenv install 2.6.3
rbenv rehash
gem install bundler
```

## Install local dependencies

```bash
bundle install
```

# Run tests

```bash
bundle exec rspec
```

# Run the server

```bash
bundle exec rackup
```

The previous command runs python 2 by default. However can run it explicitly this way:

```bash
bundle exec rackup config2.ru
```

You can run python 3 this way:

```bash
bundle exec rackup config3.ru
```


# Deploy docker images

```bash
docker login

./build_worker.sh
docker push mumuki/mumuki-python2-worker:<CURRENT_VERSION>
docker push mumuki/mumuki-python3-worker:<CURRENT_VERSION>
```
