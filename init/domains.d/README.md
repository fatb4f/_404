# domains.d fragment contract

`domains.d/<tool>/<tool>.yml` is the human-friendly declarative profile for a tool/domain.

`domains.d/<tool>/<tool>.override.py` is optional and should be rare.

Override contract:

- receive one fragment dictionary
- return one normalized fragment dictionary
- no side effects
- no filesystem writes
- no network calls

Composition pipeline:

```txt
src/domains/seed.json
  + domains.d/*/*.json|*.yml
  + optional local override
  -> src/domains/seed.composed.json
  -> src/gen/domain.py
```

The noninteractive shell fragment owns the login-shell loader and bash startup
files. The interactive shell fragment owns the generated `.zshenv` and `.zshrc`
startup files.

YAML support uses PyYAML when available. JSON-compatible `.yml` fragments are also accepted without PyYAML.
