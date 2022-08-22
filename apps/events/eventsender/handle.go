package function

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	cloudevents "github.com/cloudevents/sdk-go/v2"
	event "github.com/cloudevents/sdk-go/v2/event"
)

const sinkEnvVar string = "K_SINK"

var client cloudevents.Client
var nextMessageID int = 0

// Handle an HTTP Request.
func Handle(ctx context.Context, res http.ResponseWriter, req *http.Request) {
	log.Printf("INFO: Handle invoked by request %#v\n", req)
	ensureClient()
	sendNextEvent()
}

// ensureClient ensures cloudEvents clients has been initialized
func ensureClient() error {
	if client != nil {
		log.Printf("INFO: using existing client\n")
		return nil
	}

	sinkURL, found := os.LookupEnv(sinkEnvVar)
	if !found {
		err := fmt.Errorf("FATAL: did not find value for %s env var to configure sink", sinkEnvVar)
		log.Print(err)
		return err
	} else {
		log.Printf("INFO: sink configured: %s\n", sinkURL)
	}

	p, err := cloudevents.NewHTTP(cloudevents.WithTarget(sinkURL))
	if err != nil {
		err := fmt.Errorf("FATAL: failed to create transport: %w", err)
		log.Print(err)
		return err
	}

	c, err := cloudevents.NewClient(p)
	if err != nil {
		err := fmt.Errorf("FATAL: failed to create client, %w", err)
		log.Print(err)
		return err
	} else {
		log.Printf("INFO: created new client\n")
	}
	client = c
	return nil
}

func sendNextEvent() {
	e := event.New(event.CloudEventsVersionV1)
	e.SetSpecVersion(event.CloudEventsVersionV1)
	e.SetID(fmt.Sprintf("%d", nextMessageID))
	e.SetSource("https://joshgav.com/eventsender")
	e.SetType(cloudevents.ApplicationJSON)
	e.SetData(cloudevents.ApplicationJSON, map[string]string{"specversion": "1.0", "message": "Hello world"})

	log.Printf("INFO: event context to send:\n%s\n", e.Context.String())
	log.Printf("INFO: event to send:\n%s\n", e.String())
	result := client.Send(context.Background(), e)
	fmt.Printf("INFO: result of send:\n%s\n", result)

	nextMessageID++
}
