
# AWS CodePipeline Sandbox

1. Create a GitHub personal access token
1. Export the token to command line

    ```sh
    export GITHUB_TOKEN=blah-blah-blah
    ```

1. Run terraform

    ```sh
    cd terraform
    terraform init
    terraform apply
    ```

## References

* [Use GitHub and the CodePipeline CLI to Create and Rotate Your GitHub Personal Access Token on a Regular Basis](https://docs.aws.amazon.com/codepipeline/latest/userguide/GitHub-authentication.html#GitHub-rotate-personal-token-CLI)
