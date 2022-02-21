# 1Password Secrets Buildkite Plugin

A [Buildkite Plugin](https://buildkite.com/docs/agent/v3/plugins) to read secrets from 1Password vault using the 1Password CLI.

## Example

```yml
steps:
  - command: echo "Skips checking out Git project in checkout" 
    plugins:
      - tapendium/1password#0.0.1:
          env:
            SECRET_A:
              secret-uuid: "secret-a-item-uuid"
              field: "item-secret-in-this-field" 
            SECRET_B:
              secret-uuid: "secret-b-item-uuid"
              field: "item-secret-in-password-field" 
```
