# Contributing to TALib.jl

While direct code contributions are not accepted, your feedback and suggestions are valuable! This project welcomes:
- Bug reports
- Feature requests
- Documentation improvements

## How to contribute

### Reporting bugs

If you find a bug, please open an issue using the [Bug Report](https://github.com/bgtpeeters/TALib.jl/issues/new?template=bug_report.md) template. Include:
- A clear description of the issue
- Steps to reproduce
- Expected vs. actual behavior
- Your environment details

### Suggesting features

Have an idea for a new indicator or improvement? Use the [Feature Request](https://github.com/bgtpeeters/TALib.jl/issues/new?template=feature_request.md) template and provide:
- A clear description of what you'd like to see
- The use case and why it's valuable
- Any relevant TA-Lib function references

### Improving documentation

If you notice any documentation that could be clearer or more helpful, please open an issue with your suggestions.

## Running the tests

If you'd like to verify behavior locally, you can run the tests:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

This helps ensure any reported issues aren't due to environment differences.
