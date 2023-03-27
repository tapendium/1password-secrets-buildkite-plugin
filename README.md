# 1Password Secrets Buildkite Plugin

A [Buildkite Plugin](https://buildkite.com/docs/agent/v3/plugins) to read secrets from 1Password using the 1Password CLI. 

It uses [1Password Connect Server](https://developer.1password.com/docs/ci-cd/) and requires the host details and an access token to access the instance.

## Example

```yml
steps:
  - command: 'echo \$SECRET_A'
    plugins:
      - tapendium/1password-secrets#v2.0.0:
          connect_host: http://secrets.services.local
          connect_token: arn:aws:secretsmanager:aws-region:1234567890:secret:api-token-secret-name
          env:
            SECRET_A: "op://<vault>/<item>[/<section>]/<field>"
            SECRET_B: "op://production/database/password"
```

### Setting Connect Server host details and API token via environment variables

Connect Server host `OP_CONNECT_HOST` and/or API token `OP_CONNECT_TOKEN` may be set directly as environment variables

```yml
steps:
  - command: 'echo \$SECRET_A'
    plugins:
      - tapendium/1password-secrets#v2.0.0:
          env:
            SECRET_A: "op://<vault>/<item>[/<section>]/<field>"
            SECRET_B: "op://production/database/password"
```


## Developing

To run the tests:

```bash
docker-compose run --rm tests
```

## License

[MIT](https://opensource.org/licenses/MIT)
