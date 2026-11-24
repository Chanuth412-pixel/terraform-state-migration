# Starting-Environment Tests

Run baseline tests from the repository root:

```bash
bash tests/run-baseline.sh
```

The baseline suite validates Terraform syntax, the production and sandbox states, emergency capacity, deterministic concurrent deployment, protected production, and reset behavior.

## Evaluator specification

The separate specification in `tests/evaluator_spec.md` describes state and plan checks for a future split-state solution. It contains no reference implementation or private grading implementation.