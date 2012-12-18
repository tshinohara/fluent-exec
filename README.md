# Fluent-Exec

Log command's exit status, output and runtime to fluentd.

## Installation

Install fluent-exec as a gem:

    $ gem install fluent-exec

## Usage

    $ fluent-exec -t echo.test echo 'testing...'
    testing...

will log this record with tag `echo.test`:

    {
      "command": ["echo", "testing..."],
      "exitstatus": 0,
      "stdout": "testing...\n",
      "stderr": "",
      "runtime": 0.004784
    }

Lookup `fluent-exec --help` for more info.

    Usage: fluent-exec [options] [--] command...
    
        -t, --tag TAG                    Tag to use (default fluent.exec)
        -h, --host HOST                  Host to send (default localhost)
        -p, --port PORT                  Port to send (default 24224)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
