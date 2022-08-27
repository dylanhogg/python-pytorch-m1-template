.EXPORT_ALL_VARIABLES:
PROJECT=todo
BUCKET=todo
PROFILE=default
DATA_FOLDER=data
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh

## Create conda PyTorch environment
create-conda-env:
	./create-conda-pytorch-env.sh
	$(CONDA_ACTIVATE); conda activate ./env; conda list --export > requirements_conda_export.txt

## Clean conda environment
clean-conda-env:
	rm -rf env

## Info on conda activate
conda-activate:
	@echo "I don't run well from a Makefile, just do: 'conda activate ./env' then 'conda deactivate' later"

## Conda list
conda-list:
	$(CONDA_ACTIVATE); conda activate ./env; conda list

## Python env info
python-info:
	$(CONDA_ACTIVATE); conda activate ./env; python --version; which -a python

## Run jupyter lab
jupyter:
	$(CONDA_ACTIVATE); conda activate ./env; PYTHONPATH='./src' jupyter lab

## Run the app
run:
	$(CONDA_ACTIVATE); conda activate ./env; PYTHONPATH='./src' python -m app req1 --optional-arg opt1

## App help message
run_help:
	$(CONDA_ACTIVATE); conda activate ./env; PYTHONPATH='./src' python -m app --help

## Run unit tests
test:
	$(CONDA_ACTIVATE); conda activate ./env; PYTHONPATH='./src' pytest -vvv -s --ignore=env

## Run black code formatter
black:
	$(CONDA_ACTIVATE); conda activate ./env; black  --line-length 120 .

## Run flake8 linter
flake8:
	$(CONDA_ACTIVATE); conda activate ./env; flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	$(CONDA_ACTIVATE); conda activate ./env; flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

## Upload Data to S3
sync_data_to_s3:
	aws s3 sync $(DATA_FOLDER)/ s3://$(BUCKET)/$(PROJECT)/ --profile $(PROFILE) --exclude ".*"

## Download Data from S3
sync_data_from_s3:
	aws s3 sync s3://$(BUCKET)/$(PROJECT)/ $(DATA_FOLDER)/ --profile $(PROFILE) --exclude ".*"

## Create asitop venv
venv_asitop:
	python3 -m venv venv_asitop
	source venv_asitop/bin/activate ; pip install --upgrade pip ; python3 -m pip install asitop
	source venv_asitop/bin/activate ; pip freeze > requirements_freeze.txt

## Run asitop (Performance monitoring CLI tool for Apple Silicon)
asitop:
	source venv_asitop/bin/activate ; sudo asitop

## Self documenting commands
.DEFAULT_GOAL := help
help:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
