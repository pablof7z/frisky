# frisky [![Build Status](https://secure.travis-ci.org/heelhook/frisky.png?branch=development)](https://travis-ci.org/heelhook/frisky) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/heelhook/frisky)
A playful scm platform for MSR (mining software repositories)

http://heelhook.github.com/frisky



## What this is

Frisky is an engine to cache and process SCM repositories in bulk, supporting initially Git and particularly Github
as a discovery source.

## Goal

The main goal of Frisky, as a platform, is to provide an environment where any developer can validate and test algorithms to extract knowledge out of Git data.

## How it works

Frisky allows you to create classifiers that mine information from software repositories, handling the specifics of
data gathering, caching and storage. Classifiers can interact with each others' data by consuming and setting objects' tags.

Classifiers are Ruby classes that respond to mining events.

```ruby
class CommitCountClassifier < Classifier
  commit :update_commit_count, if: lambda {|commit| commit.files_type('Ruby').any? }

  def update_file_loc(commit)
    @repository.increment(:commit_count, 1)
  end
end
```

The `commit` class method specifies a callback method that will be called whenever a new commit
that contains at least one file of `Ruby` code.

### A more useful classifier

The following classifier will run `reek` on ruby files on each commit, gathering
the results on each commit object to get a clear picture of the evolution of code smells
on each commit.

We also want to persist this information to the committer responsible for the delta so
we can find out how each user has performed over time.


```ruby
class ReekClassifier < Classifier
  commit :run_reek_on_commit

  def run_reek_on_commit(commit)
    commit.file_types 'Ruby' do |file|
      # Only get reek when we have something to compare against
      next unless commit.parent

      reek_v2 = file_reek_on commit.id, file
      reek_v1 = file_reek_on commit.parent.id, file
      reek_delta = reek_v2 - reek_v1

      commit.increment(:reek, reek_delta)
      commit.author.increment(:reek, reek_delta)
    end
  end

  def file_reek_on(commit_id, file_path)
    cached_output :reek, commit_id, file_path
  end

  # Get reek output for an IO
  def output_reek(io)
    # ...
  end
end

```

Here the method `file_reek_on` is called to gather the `reek` score of each file on each commit,
gathering the score of the parent of that file and storing the delta associated to the commit and to the author.

The method `cached_output` will call `output_reek` only when the score hasn't been generated
previously.

## Setup

Frisky's architecture is composed of `schedulers` and classifiers.

### Infrastructure requirements

Frisky requires the following software stack to run

  - mongodb >= 2.2
  - redis >= 1.4
  - ruby 1.9

### Installing

A simple `clone` will do:

```
git clone https://github.com/heelhook/frisky.git
cd frisky
bundle install
```

### Configuring

The main configuration file is `frisky.yml`

```
github:
  keys:
    - client_id:client_secret
mongo: mongodb://127.0.0.1/frisky
redis: 127.0.0.1
```

The configuration is self-explanatory, the only thing that needs clarification is the `github.keys` key,
the key is an array of `client_id:client_secret` duples, on startup frisky will pick a random key and use it
throughout the session.

### Running

```
bundle exec bin/frisky-event-scheduler -v
```

Fetches github public events and caches them for further processing. Can be run in parallel in multiple hosts.

```
bundle exec bin/frisky-classifiers -v
```

Loads classifiers models and processes events through them. Can be run in parallel in multiple hosts.

## Code structure

This is a brief code description to help organize

`bin` -- Skeleton wrappers that run commands in `lib/frisky/commands`  
`classifiers` -- Directory where classifiers are stored and loaded by default  
`lib/frisky/classifier` -- Modules that support specific features of the classifiers  
`lib/frisky/models` -- Data models with lazy loading through [ClassProxy][0]  
`lib/frisky/models/proxy_base` -- Primitives for the data models

### Data models

Data models provide a lazy loading abstraction to the Github API, so that when
a request is made of a model for some data that hasn't been loaded, it will fallback to the Github API,
on a per-required basis, this is to optimize the number of calls made to the endpoint.

## License

### The MIT License (MIT)

Copyright (c) 2013 Pablo Fernandez

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[0]: https://github.com/heelhook/class-proxy
