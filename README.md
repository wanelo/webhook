Webhook
=======

Receive webhooks and publish their contents to RabbitMQ.

## Development

Running tests:

```bash
bundle
bundle exec rake reset
bundle exec rake
```

## Configuration

Create a `publishers.yml` in the `config` directory. This file is ignored by git.

```yaml
connection:
  host: '127.0.0.1'
  port: 5672
  ssl: false
  vhost: '/'
  username: 'guest'
  password: 'guest'

exchange: my.topic
```

This has a hard assumption that the exchange is a topic exchange configured with
`durable: true`.
