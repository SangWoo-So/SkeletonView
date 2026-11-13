# Harness

Verification app for the diffable data source support. It compiles the library sources directly, so no Xcode project is needed.

```sh
./build.sh          # builds build/Harness.app
./run.sh            # runs every check in one launch (~20 s once the simulator is booted)
./run.sh cv-fill    # runs a single scenario
./demo.sh           # looping visual demo: show → apply while the skeleton is shown → hide
```

The simulator is `$DEVICE` if set, else the first booted one, else the first available iPhone.
Each check logs `RESULT[<scenario>]: ...`; the scenarios are listed in `allScenarios` in `main.swift`.
`leak-*` scenarios aren't part of the full run: any view that showed a skeleton is never released (already the case on `main`).
