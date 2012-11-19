frisky
======

A playful scm mirror platform for MSR (mining software repositories)

[![Build Status](https://secure.travis-ci.org/heelhook/frisky.png?branch=development)](https://travis-ci.org/heelhook/frisky)

## What this is

Frisky is an engine to cache and process SCM repositories, supporting initially Git and particularly Github
as a discovery source.

## How it works

Frisky allows you to create classifiers that mine information from software repositories, handling the specifics of
data gathering, caching and storage. Classifiers can interact with each others' data by consuming and setting objects' tags.

Classifiers are Ruby classes that respond to mining events.

```
class CommitCountClassifier << Classifier
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


```
class ReekClassifier << Classifier
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
