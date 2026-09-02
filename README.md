# rails_event_app
Rails Event Driven Application

### Environment variable configuration
- Create a .env file, add the below key and values in the project root folder

BILLETTO_ACCESS_KEY_ID=

BILLETTO_ACCESS_KEY_SECRET=

CLERK_PUBLISHABLE_KEY=

CLERK_SECRET_KEY=

CLERK_SIGN_IN_URL=https://needed-dove-4601.accounts.dev/sign-in

### Run the application
docker-compose build

docker-compose up

### Rake task to load events
docker exec -it events_voting-web-1 /bin/bash

rails billetto:import_events

### Access the application
http://localhost:3000

