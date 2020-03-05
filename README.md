
# AWS CodePipeline Sandbox

1. Create a GitHub personal access token
1. Export the token to command line

    ```sh
    export GITHUB_TOKEN=blah-blah-blah
    ```

1. Run terraform

    ```sh
    cd pipeline
    terraform init
    terraform apply
    ```

## References

* [Use GitHub and the CodePipeline CLI to Create and Rotate Your GitHub Personal Access Token on a Regular Basis](https://docs.aws.amazon.com/codepipeline/latest/userguide/GitHub-authentication.html#GitHub-rotate-personal-token-CLI)
* [Action Structure Requirements in CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements)
* [Building a Continuous Delivery Pipeline for a Lambda Application with AWS CodePipeline](https://docs.aws.amazon.com/lambda/latest/dg/build-pipeline.html)
* [Docker Images Provided by CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html)
