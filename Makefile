#VAR_FILE="-var-file=./vars.json"
TEMPLATE_FILE="template.json"
VALIDATE_OPTS="-syntax-only"

build: clean
	@echo "========== Virtual Machine Buiding... =========="
	@echo
	@echo "Exporting the environment variables"
	@source .env
	@echo 
	@echo "Packer starts to build the pipeline"
	@packer build \
			"${TEMPLATE_FILE}" 
	echo "========== End =========="

validate:
	@packer validate "${VALIDATE_OPTS}" \
					 "${TEMPLATE_FILE}" 

clean:
		@rm -fr ./build-output
		@rm -fr ./packer_cache
		@echo "The removal of the dir <build-output> completed!"
