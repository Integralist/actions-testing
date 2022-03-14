## Gotchas

- Use single quotes when using operators like `==` (double quotes are invalid).

## Scheduled Jobs (cron)

```yaml
on:
  push:
  schedule:
    - cron: '0 0 1 * *'   # https://crontab.guru/every-month
    - cron: '*/5 * * * *' # https://crontab.guru/every-5-minutes
```

> **NOTE**: We don't specify a value for `push` key which means run whenever a push is triggered on any branch.

## Automatically cancel in-flight workflows

The `concurrency` setting allows you to restrict a workflow to one 'group' at a time. 

Now if you're working on a PR which executes a workflow, then the workflow is likely getting run on every single push to the PR. 

An example of why this is a problem is if you have just pushed a _broken_ commit and now you're pushing a new commit on top to fix it, then the workflow from the previous commit (the broken one) is still going to run, it's still going to use up resources but ultimately it's going to fail.

What you want to have happen is when the second commit is pushed, it cancels running the workflow on the previous commit which we know to be broken any way. Hell, it's nice to have this behaviour if you're pushing commits at just a regular pace! Why have a bunch of in-flight workflows runnings on old code.

To get this to work you set both the `concurrency` group _and_ `cancel-in-progress`:

```yaml
concurrency:
  group: ${{ github.ref_name }}
  cancel-in-progress: true
```

## Persisting Data

GitHub says you can use 'caching' or 'artifacts' to persist data between jobs. But you can also persist data by using the JSON output of one job as the `strategy.matrix` input for another job:

> **NOTE**: Not restricted to using `strategy.matrix`, you can just use the output data however you like. See [later in the README](#using-shared-job-data-to-determine-if-subsequent-job-should-run) for an example.

```yaml
name: example
on: push
jobs:
  job1:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - id: set-matrix
        run: echo "::set-output name=matrix::{\"FOO\":["abc"],\"BAR\":["xyz"]}"
  job2:
    needs: job1
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{fromJSON(needs.job1.outputs.matrix)}}
    env:
      FOO: ${{ matrix.FOO }}
      BAR: ${{ matrix.BAR }}
    steps:
      - run: echo ${{ matrix.FOO }} # abc
      - run: echo ${{ matrix.BAR }} # xyz
```

> **NOTE**: Be sure to set the value of each matrix field to a list type containing a single entry, otherwise the strategy.matrix will fail to parse the JSON format. This is because a strategy.matrix is typically used to generate multiple 'variants' of a job. By setting a single value inside a list, we ensure there is only ever one job variant generated (i.e. only one job is created), and that single job can simply reference the fields within the matrix as data points of interest.

### Clarify the cache action

The `actions/cache@v2` works like so...

```yaml
- uses: actions/cache@v2
  with:
    path: path/to/be/cached
    key: ${{ runner.os }}-my-cache-key
```

When the step that implements the action is executed (see above snippet), the cache action simply looks up the cache key (e.g. `Linux-my-cache-key`) and if it finds something in the cache, then it restores the cache to the path you specified (e.g. `path/to/be/cached`). 

If the cache action doesn't find anything in the cache, then nothing happens. 

Now the important bit: the cache action has a 'post run' event that executes once your job has finished successfully. The cache action will be run again and this time it stores whatever was in your given path into the cache using the key you said it should be stored under.

This means, when it comes to running another job, you need to ensure you define the cache action again (the same as you defined it in your first job). This is so all of what I've just explained will happen again. The only difference is that in the 'post run' event for your next job, when the action gets run again, you'll now see something like...

> Cache hit occurred on the primary key `Linux-my-cache-key`, not saving cache.

Meaning there was nothing else to do. I imagine if there were changes to the files in the given path then it would indicate the cache was updated with the latest files.

## Reusable Workflows

If you have a bunch of setup configuration that is the same between jobs, then you can move that configuration into a separate workflow file that can then be imported and used by each job in your main workflow file.

The following example, demonstrates how to _call_ (i.e. import) a reusable workflow:

```yaml
jobs:
  build:
    ...

  deploy:
    ...

  validate-foo:
    uses: integralist/actions-testing/.github/workflows/resuable-setup@main # install node, rust, setup env vars etc
    steps: 
      - ...

  validate-bar:
    uses: integralist/actions-testing/.github/workflows/resuable-setup@main # install node, rust, setup env vars etc
    steps: 
      - ...
```

An example implementation of a reusable workflow would be:

```yaml
name: Reusable workflow for validation scripts
on:
  workflow_call:
    inputs:
      install_node:
        type: bool
      name:
        required: true
        type: string
      description:
        required: true
        type: string
      script:
        required: true
        type: string

jobs:
  validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - if: ${{ github.event_name != 'schedule' }}
        run: exit 1
      - if: ${{ inputs.install_node }}
        name: Environment
        run: |
          echo "NODE_VERSION=$(cat .nvmrc)" >> $GITHUB_ENV
      - if: ${{ inputs.install_node }}
        uses: actions/setup-node@v2
        id: node-yarn
        with:
          node-version: "${{ env.NODE_VERSION }}"
          cache: yarn
      - name: status update
        uses: ouzi-dev/commit-status-updater@v1.1.2
        with:
          name: ${{ inputs.name }}
          description: ${{ inputs.description }}
          status: pending
      - id: validator
        run: ${{ inputs.script }}
      - if: ${{ success() }}
        name: status update
        uses: ouzi-dev/commit-status-updater@v1.1.2
        with:
          name: ${{ inputs.name }}
          description: ${{ steps.validator.outputs.description }}
          status: ${{ steps.validator.outputs.status }}
```

## Using shared job data to determine if subsequent job should run

In the following example the `bar` job will not run if the required fields `foo` and `baz` aren't set to `true`.

```yaml
  foo:
    runs-on: ubuntu-latest
    outputs:
      data: ${{ steps.footest.outputs.data }}
    steps:
      - run: |
          echo "FOO=true" >> $GITHUB_ENV
          echo "BAR=false" >> $GITHUB_ENV
          echo "BAZ=true" >> $GITHUB_ENV
      - id: footest
        run: echo ::set-output name=data::[\"foo=$FOO\", \"bar=$BAR\", \"baz=$BAZ\"]

  bar:
    needs: foo
    if: ${{ contains(needs.foo.outputs.data, 'foo=true') && contains(needs.foo.outputs.data, 'baz=true') }}
    runs-on: ubuntu-latest
    steps:
      - run: echo 'yay! we ran because the fields were set to true'
      - run: exit 1

  build:
    needs: bar
    runs-on: ubuntu-latest
    steps:
      - run: echo 'yay! this job ran as the bar job was successful'
```
