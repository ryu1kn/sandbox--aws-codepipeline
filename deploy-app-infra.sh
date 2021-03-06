#!/bin/bash

readonly lambda_package=app.zip

(cd webapp && zip -q -r9 "../$lambda_package" *)

(
    cd app-infra \
    && terraform init -no-color \
    && terraform apply -auto-approve -var="lambda_package_file=../$lambda_package" -no-color
)
