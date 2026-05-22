header:
	@echo "For work with etl stream"
expor:
	@echo "Exporting environment variables..."
	export alias RR="> "
venv:
	@echo "Creating virtual environment..."
	uv venv 
	@echo "Virtual environment created."
source:
	@echo "Activating virtual environment..."
	source .venv/bin/activate
	@echo "Virtual environment activated."
install:
	@echo "Installing dependencies..."
	pip install -r requirements.txt
	@echo "Dependencies installed."
up-redpd:
	@echo "Starting Redpanda..."
	docker-compose up redpanda -d
	@echo "Redpanda started."
	docker-compose ps
redpd-logs:
	@echo "Starting Redpanda..."
	docker-compose logs redpanda -f
ps1:
	alias ps1='PS1="> "'
