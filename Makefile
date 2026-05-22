header:
	@echo "For work with etl stream"
expor:
	@echo "Exporting environment variables..."
	echo 'PS1="> "' >> ~/.bashrc
uv:
	pip install uv
	python3 -m pip install --upgrade pip
	uv sync
	@echo "Activating virtual environment..."
	source .venv/bin/activate
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
mk:
	@echo "Making..."
	mkdir -p src/producers src/consumers src/job
#For work with postgres
up-postgres:
	@echo "Starting Postgres..."
	docker-compose up postgres -d
	@echo "Postgres started."
	docker-compose ps
logs-postgres:
	@echo "Starting Postgres..."
	docker-compose logs postgres -f
conn-pgcli:
	@echo "Connecting to Postgres..."
	uvx pgcli -h localhost -p 5432 -U postgres -d postgres
create-table:
	@echo "Creating table..."
	uv run python src/consumers/create_table.py
#FOR WORK WITH FLINK
get-flink:
	@echo "Downloading Flink..."
	#PREFIX="https://raw.githubusercontent.com/DataTalksClub/data-engineering-zoomcamp/main/07-streaming/workshop"
	#wget ${PREFIX}/Dockerfile.flink
	#wget ${PREFIX}/pyproject.flink.toml
	#wget ${PREFIX}/flink-config.yaml

build-flink:
	@echo "Building Flink..."
	docker compose up --build -d
	docker ps
up-flink:
	@echo "Building Flink..."
	docker compose up jobmanager taskmanager -d
	docker ps
run-prod-pass:
	@echo "Running producer..."
	uv run python src/producers/producer_pass_through.py

exec-manager:
	@echo "Executing Flink job manager..."
	docker compose exec jobmanager ./bin/flink run \
    	-py /opt/src/job/pass_through_job.py \
    	--pyFiles /opt/src -d
#Job has been submitted with JobID cc833bd4aa5c24f42835c0f85508fc9d
get-prod:
	#PREFIX="https://raw.githubusercontent.com/DataTalksClub/data-engineering-zoomcamp/main/07-streaming/workshop"
	#wget ${PREFIX}/src/producers/producer_realtime.py -P src/producers/
run-producer:
	@echo "Running producer..."
	uv run python src/producers/producer_realtime.py
exec-agreg:
	@echo "Executing Flink job manager..."
	docker compose exec jobmanager ./bin/flink run \
		-py /opt/src/job/aggregated_job.py \
		--pyFiles /opt/src -d
watch_psql:
	watch -n 1 'PGPASSWORD=postgres docker compose exec postgres psql -U postgres -d postgres -c "SELECT window_start, sum(num_trips) as trips, round(sum(total_revenue)::numeric, 2) as revenue FROM processed_events_aggregated GROUP BY window_start ORDER BY window_start;"'

up-all: up-redpd up-postgres up-flink	
