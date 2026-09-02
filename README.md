# rails_event_app
Rails Event Driven Application

# Run the application
docker-compose build
docker-compose up

# Rake task to load events
docker exec -it events_voting-web-1 /bin/bash
rails billetto:import_events

# Access the application
http://localhost:3000

