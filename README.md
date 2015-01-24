Webhook
=======

Receive webhooks and publish their contents to RabbitMQ.

This uses the [Lapine](https://github.com/wanelo/lapine) gem for publishing messages.
See Lapine for how to consume messages.

## Usage

This application includes a Sinatra app that listens on paths matching different Webhook
integrations. When a hook is received, its content is published to a RabbitMQ topic exchange
with a routing key matching the type of webhook.

See [Configuration](#configuration) for how to configure the RabbitMQ connection and
exchange used by Webhook.

### Stripe

A `/stripe` endpoint is registered that listens for `POST` actions with JSON content.
The `type` field of the JSON is used to construct the message routing key, prepended with
`stripe`. For instance, if a `charge.failed` webhook is received, the message published to
RabbitMQ will have a routing key of `stripe.charge.failed`.

The full content of the webhook will be published as the message body.

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
