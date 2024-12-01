# -----------------
# --- Variables ---
# -----------------
LAMBDA_NAME := s3_wav_transcriber
IMAGE_TAG := latest

# ------------------------------------------------
# --- Docker Config (Fixed; No need to change) ---
# ------------------------------------------------
IMAGE_NAME := $(LAMBDA_NAME)

# ---------------------------------------------
# --- AWS Config (Fixed; No need to change) ---
# ---------------------------------------------
# AWS_ACCOUNT_ID is set as an environment variable
AWS_REGION := ap-northeast-1
ECR_URI := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
ECR_REPOSITORY_URI := $(ECR_URI)/$(LAMBDA_NAME)_dev


# ------------------
# --- Make Rules ---
# ------------------

.PHONY: build
build:
	docker build ./lambda/$(LAMBDA_NAME) -t $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: push
push:
	aws ecr get-login-password \
		--region $(AWS_REGION) \
		| docker login --username AWS --password-stdin $(ECR_URI)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(ECR_REPOSITORY_URI):$(IMAGE_TAG)
	docker push $(ECR_REPOSITORY_URI):$(IMAGE_TAG)

.PHONY: run
run:
	docker run -p 9000:8080 $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: test
test:
	curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

.PHONY: create-repo-dev
create-repo-dev:
	aws ecr get-login-password \
		--region $(AWS_REGION) \
		| docker login --username AWS --password-stdin $(ECR_URI)
	aws ecr create-repository \
		--repository-name $(LAMBDA_NAME)_dev \
		--region $(AWS_REGION) \
		--image-scanning-configuration scanOnPush=true \
		--image-tag-mutability MUTABLE

.PHONY: create-repo-prod
create-repo-prod:
	aws ecr get-login-password \
		--region $(AWS_REGION) \
		| docker login --username AWS --password-stdin $(ECR_URI)
	aws ecr create-repository \
		--repository-name $(LAMBDA_NAME)_prod \
		--region $(AWS_REGION) \
		--image-scanning-configuration scanOnPush=true \
		--image-tag-mutability IMMUTABLE

.PHONY: init
init:
	terraform -chdir=./infra/envs/dev init -upgrade

.PHONY: plan
plan:
	terraform -chdir=./infra/envs/dev plan

.PHONY: apply
apply:
	terraform -chdir=./infra/envs/dev apply \
		-auto-approve \
		-replace="module.lambda_s3_handler.aws_lambda_function.s3_handler" \
		-replace="module.lambda_s3_handler.aws_s3_bucket_notification.s3_notification"

.PHONY: destroy
destroy:
	terraform -chdir=./infra/envs/dev destroy -auto-approve

.PHONY: delete-repo-dev
delete-repo:
	aws ecr delete-repository \
		--repository-name $(LAMBDA_NAME)_dev \
		--region $(AWS_REGION) \
		--force

.PHONY: delete-repo-prod
delete-repo-prod:
	aws ecr delete-repository \
		--repository-name $(LAMBDA_NAME)_prod \
		--region $(AWS_REGION)
