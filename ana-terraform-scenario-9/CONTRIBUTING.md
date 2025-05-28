# Contributing to Serverless API Project

First off, thank you for considering contributing to this project! 🎉

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

* Use a clear and descriptive title
* Describe the exact steps to reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed and what behavior you expected
* Include logs and screenshots if possible

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

* Use a clear and descriptive title
* Provide a detailed description of the proposed functionality
* Explain why this enhancement would be useful
* List any additional requirements or considerations

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Ensure all tests pass
4. Make sure your code follows the existing style
5. Update the documentation if needed

## Development Process

1. Install prerequisites:
   ```bash
   pre-commit install
   npm install
   ```

2. Make your changes:
   * Follow the existing code style
   * Add comments for complex logic
   * Update documentation as needed

3. Test your changes:
   ```bash
   # Run pre-commit hooks
   pre-commit run --all-files

   # Deploy and test infrastructure
   ./deploy.sh

   # Run load tests
   npm test
   ```

4. Clean up after testing:
   ```bash
   ./cleanup.sh
   ```

## Style Guide

### Terraform

* Use consistent naming conventions
* Include descriptions for all variables and outputs
* Use data sources when possible instead of hardcoding values
* Tag all resources appropriately
* Follow security best practices

### JavaScript

* Use ES6+ features
* Add proper error handling
* Include logging for important operations
* Document complex functions
* Use async/await for asynchronous operations

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

## Documentation

* Update README.md with any new features or changes
* Document all new variables in terraform.tfvars
* Include examples for new functionality
* Update troubleshooting guide if needed

## Testing

Before submitting a PR, ensure:

1. All pre-commit hooks pass
2. Infrastructure deploys successfully
3. Load tests complete without errors
4. All resources can be cleaned up properly
5. Documentation is updated

## Security

* Never commit sensitive information
* Use IAM roles with minimum required permissions
* Enable encryption where possible
* Follow AWS security best practices
* Report security issues privately

## Questions?

If you have questions, please open an issue or reach out to the maintainers.

Thank you for contributing! 🚀