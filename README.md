# 1Password Secrets Buildkite Plugin

A [Buildkite Plugin](https://buildkite.com/docs/agent/v3/plugins) to read secrets from 1Password using the 1Password CLI.

## Example

```yml
steps:
  - command: 'echo \$SECRET_A' 
    plugins:
      - tapendium/1password-secrets:
          env:
            SECRET_A:
              secret-uuid: "secret-a-item-uuid"
              field: "item-secret-in-this-field" 
            SECRET_B:
              secret-uuid: "secret-b-item-uuid"
              field: "item-secret-in-password-field" 
```

## License

[MIT](https://opensource.org/licenses/MIT)
