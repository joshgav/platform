package function

import (
	"context"
	"log"

	"github.com/cloudevents/sdk-go/v2/event"
)

// Handle an event.
func Handle(ctx context.Context, e event.Event) error {
	log.Printf("INFO: Received event:\n%s\n", e.String())
	log.Println("---")
	log.Printf("INFO: Received event context:\n%s\n", e.Context.String())

	return nil
}

/*
Other supported function signatures:
	Handle()
	Handle() error
	Handle(context.Context)
	Handle(context.Context) error
	Handle(event.Event)
	Handle(event.Event) error
	Handle(context.Context, event.Event)
	Handle(context.Context, event.Event) error
	Handle(event.Event) *event.Event
	Handle(event.Event) (*event.Event, error)
	Handle(context.Context, event.Event) *event.Event
	Handle(context.Context, event.Event) (*event.Event, error)
*/
